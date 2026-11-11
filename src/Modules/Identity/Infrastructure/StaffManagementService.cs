using System.Data;
using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces;
using GiysiGo.Modules.Identity.Application.Interfaces.Authorization;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Application.Models;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class StaffManagementService(ICurrentUser currentUser, ITransactionRunner transactions,
        IStaffManagementRepository directory, IIdentityAccessRepository access,
        IIdentityAuthorizationRepository authorization, IStaffAssignmentAuthorizer authorizer,
        IStoreScopeReader stores) : IStaffManagementService
    {
        public Task<Guid> CreateCorporateAsync(string name, CancellationToken token = default)
        {
            if (string.IsNullOrWhiteSpace(name) || name.Length > 200)
                throw new ArgumentException("Company name must contain 1 to 200 characters.", nameof(name));
            var actor = Actor();
            return transactions.ExecuteAsync(async (connection, transaction, cancellation) =>
            {
                await RequirePlatformAsync(actor, connection, transaction, cancellation);
                return await directory.CreateCorporateAsync(name.Trim(), connection, transaction, cancellation);
            }, token);
        }

        public Task SetCorporateActiveAsync(Guid id, bool isActive, CancellationToken token = default)
        {
            ValidateId(id);
            var actor = Actor();
            return transactions.ExecuteAsync(async (connection, transaction, cancellation) =>
            {
                await RequirePlatformAsync(actor, connection, transaction, cancellation);
                await directory.SetCorporateActiveAsync(id, isActive, connection, transaction, cancellation);
                return true;
            }, token);
        }

        public Task ChangeAssignmentAsync(Guid corporateId, Guid? storeId, Guid userId, Guid roleId, bool grant, CancellationToken token = default)
        {
            ValidateId(corporateId); ValidateId(userId); ValidateId(roleId);
            if (storeId.HasValue) ValidateId(storeId.Value);
            var actor = Actor();
            return transactions.ExecuteAsync(async (connection, transaction, cancellation) =>
            {
                if (!await authorizer.CanManageAsync(actor, userId, roleId, corporateId, storeId, connection, transaction, cancellation))
                    throw new UnauthorizedAccessException("Assignment is outside the actor's scope or role hierarchy.");
                if (storeId.HasValue)
                {
                    if (grant) await access.GrantStoreAssignmentAsync(userId, storeId.Value, roleId, connection, transaction, cancellation);
                    else await access.RevokeStoreAssignmentAsync(userId, storeId.Value, roleId, connection, transaction, cancellation);
                }
                else
                {
                    if (grant) await access.GrantCorporateMembershipAsync(userId, corporateId, roleId, connection, transaction, cancellation);
                    else await access.RevokeCorporateMembershipAsync(userId, corporateId, roleId, connection, transaction, cancellation);
                }
                return true;
            }, IsolationLevel.Serializable, token);
        }

        public Task<StaffMemberPage> GetMembersAsync(Guid corporateId, Guid? storeId, int page, int pageSize, CancellationToken token = default)
        {
            ValidateId(corporateId);
            if (storeId.HasValue) ValidateId(storeId.Value);
            if (page < 1 || pageSize is < 1 or > 100) throw new ArgumentException("Invalid pagination.");
            var actor = Actor();
            return transactions.ExecuteAsync(async (connection, transaction, cancellation) =>
            {
                if (storeId.HasValue)
                {
                    var store = await stores.GetScopeAsync(storeId.Value, connection, transaction, cancellation);
                    if (store is null || !store.IsActive || store.CorporateId != corporateId)
                        throw new UnauthorizedAccessException("Store is outside the requested corporate scope.");
                }
                await RequireAsync(actor, corporateId, storeId, connection, transaction, cancellation);
                return await directory.GetMembersAsync(corporateId, storeId, page, pageSize, connection, transaction, cancellation);
            }, token);
        }

        public Task<IReadOnlyList<StaffScopeAccess>> GetMyAccessAsync(CancellationToken token = default)
        {
            var actor = Actor();
            return transactions.ExecuteAsync<IReadOnlyList<StaffScopeAccess>>(async (connection, transaction, cancellation) =>
            {
                var rows = await directory.GetAccessAsync(actor, connection, transaction, cancellation);
                var result = new List<StaffScopeAccess>();
                foreach (var group in rows.Where(row => row.StoreId is null).GroupBy(row => row.CorporateId))
                    result.Add(Summary(group.Key is null ? "GLOBAL" : "CORPORATE", group.Key, null, group.First().CorporateName, group));

                foreach (var group in rows.Where(row => row.StoreId.HasValue).GroupBy(row => row.StoreId!.Value))
                {
                    var store = await stores.GetScopeAsync(group.Key, connection, transaction, cancellation);
                    if (store is null || !store.IsActive) continue;
                    var corporate = await directory.GetCorporateAsync(store.CorporateId, connection, transaction, cancellation);
                    if (corporate is not { IsActive: true, DeleteDate: null }) continue;
                    var inherited = rows.Where(row => row.StoreId is null && (row.CorporateId is null || row.CorporateId == store.CorporateId));
                    result.Add(Summary("STORE", store.CorporateId, store.StoreId, corporate.Name, group.Concat(inherited)));
                }
                return result;
            }, token);
        }

        private async Task RequireAsync(Guid actor, Guid? corporateId, Guid? storeId, DbConnection connection, DbTransaction transaction, CancellationToken token)
        {
            if (!await authorization.HasPermissionAsync(actor, PermissionCodes.StoreStaffManage, corporateId, storeId, connection, transaction, token))
                throw new UnauthorizedAccessException("Staff management permission is required.");
        }

        private async Task RequirePlatformAsync(Guid actor, DbConnection connection, DbTransaction transaction, CancellationToken token)
        {
            var rows = await directory.GetAccessAsync(actor, connection, transaction, token);
            if (!rows.Any(row => row.CorporateId is null && row.StoreId is null
                && row.RoleCode == "PlatformAdmin" && row.PermissionCode == PermissionCodes.StoreStaffManage))
                throw new UnauthorizedAccessException("An active platform administrator is required.");
        }

        private Guid Actor() => currentUser.IsAuthenticated && currentUser.UserId is Guid id && id != Guid.Empty
            ? id : throw new UnauthorizedAccessException("Authentication is required.");

        private static void ValidateId(Guid id)
        {
            if (id == Guid.Empty) throw new ArgumentException("Identifiers cannot be empty.");
        }

        private static StaffScopeAccess Summary(string scope, Guid? corporateId, Guid? storeId, string? corporateName, IEnumerable<StaffAccessRow> rows)
        {
            var snapshot = rows.ToArray();
            return new StaffScopeAccess(scope, corporateId, storeId, corporateName,
                snapshot.Select(row => row.RoleCode).Distinct().Order(StringComparer.Ordinal).ToArray(),
                snapshot.Select(row => row.PermissionCode).OfType<string>().Distinct().Order(StringComparer.Ordinal).ToArray());
        }
    }
}

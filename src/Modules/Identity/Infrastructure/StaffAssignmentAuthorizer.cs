using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Authorization;
using GiysiGo.Modules.Identity.Infrastructure.Repositories;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class StaffAssignmentAuthorizer(IStoreScopeReader? storeScopeReader = null)
        : IdentityCommandRepositoryBase, IStaffAssignmentAuthorizer
    {
        public async Task<bool> CanManageAsync(Guid actorUserId, Guid targetUserId, Guid targetRoleId,
            Guid? corporateId, Guid? storeId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default)
        {
            if (actorUserId == Guid.Empty || targetUserId == Guid.Empty || targetRoleId == Guid.Empty
                || actorUserId == targetUserId || corporateId == Guid.Empty || storeId == Guid.Empty
                || (corporateId is null && storeId is null))
            {
                return false;
            }

            if (storeId.HasValue)
            {
                if (storeScopeReader is null)
                {
                    throw new InvalidOperationException("IStoreScopeReader is required to manage store staff.");
                }

                var scope = await storeScopeReader.GetScopeAsync(storeId.Value, connection, transaction, cancellationToken);
                if (scope is null || scope.StoreId != storeId.Value || !scope.IsActive
                    || scope.CorporateId == Guid.Empty
                    || (corporateId.HasValue && corporateId.Value != scope.CorporateId))
                {
                    return false;
                }

                corporateId = scope.CorporateId;
            }

            return await connection.QuerySingleAsync<bool>(Procedure("[identity].[spCanManageStaffAssignment]",
                new { ActorUserId = actorUserId, TargetUserId = targetUserId, TargetRoleId = targetRoleId,
                    CorporateId = corporateId, StoreId = storeId }, connection, transaction, cancellationToken));
        }
    }
}

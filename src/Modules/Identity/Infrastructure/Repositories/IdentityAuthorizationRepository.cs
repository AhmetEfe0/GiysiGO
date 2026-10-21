using System.Data.Common;
using Dapper;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;

namespace GiysiGo.Modules.Identity.Infrastructure.Repositories
{
    public sealed class IdentityAuthorizationRepository : IdentityCommandRepositoryBase, IIdentityAuthorizationRepository
    {
        public Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId, Guid? storeId,
            DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => connection.QuerySingleAsync<bool>(Procedure("[identity].[spHasPermission]",
                new { UserId = userId, PermissionCode = permissionCode, CorporateId = corporateId, StoreId = storeId },
                connection, transaction, cancellationToken));

        public Task<bool> CanManageStaffAssignmentAsync(Guid actorUserId, Guid targetUserId, Guid targetRoleId,
            Guid? corporateId, Guid? storeId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default)
            => connection.QuerySingleAsync<bool>(Procedure("[identity].[spCanManageStaffAssignment]",
                new { ActorUserId = actorUserId, TargetUserId = targetUserId, TargetRoleId = targetRoleId,
                    CorporateId = corporateId, StoreId = storeId }, connection, transaction, cancellationToken));
    }
}

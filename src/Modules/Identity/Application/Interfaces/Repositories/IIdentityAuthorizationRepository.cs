using System.Data.Common;

namespace GiysiGo.Modules.Identity.Application.Interfaces.Repositories
{
    public interface IIdentityAuthorizationRepository
    {
        Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId, Guid? storeId,
            DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);

        Task<bool> CanManageStaffAssignmentAsync(Guid actorUserId, Guid targetUserId, Guid targetRoleId,
            Guid? corporateId, Guid? storeId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default);
    }
}

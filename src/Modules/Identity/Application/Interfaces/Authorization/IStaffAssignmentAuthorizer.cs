using System.Data.Common;

namespace GiysiGo.Modules.Identity.Application.Interfaces.Authorization
{
    public interface IStaffAssignmentAuthorizer
    {
        Task<bool> CanManageAsync(Guid actorUserId, Guid targetUserId, Guid targetRoleId,
            Guid? corporateId, Guid? storeId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default);
    }
}

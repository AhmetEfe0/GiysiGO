using System.Data.Common;

namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface ITransactionalPermissionChecker
    {
        // Use Serializable isolation to retain authorization locks through the protected write.
        Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId, Guid? storeId,
            DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
    }
}

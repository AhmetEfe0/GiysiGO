using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class PausingOfferingPermissionChecker(ITransactionalPermissionChecker inner, bool beforeCheck,
        TaskCompletionSource<DbTransaction> paused, Task resume) : ITransactionalPermissionChecker
    {
        public async Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId, Guid? storeId,
            DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            if (beforeCheck) await PauseAsync(transaction, cancellationToken);
            var allowed = await inner.HasPermissionAsync(userId, permissionCode, corporateId, storeId, connection, transaction, cancellationToken);
            if (!beforeCheck && allowed) await PauseAsync(transaction, cancellationToken);
            return allowed;
        }

        private async Task PauseAsync(DbTransaction transaction, CancellationToken token)
        {
            if (paused.TrySetResult(transaction)) await resume.WaitAsync(TimeSpan.FromSeconds(20), token);
        }
    }
}

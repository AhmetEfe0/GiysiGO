using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Identity.Tests
{
    public sealed class FixtureStoreScopeReader(Guid storeId, Guid corporateId, bool isActive = true) : IStoreScopeReader
    {
        public Task<StoreScopeSnapshot?> GetScopeAsync(Guid requestedStoreId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            StoreScopeSnapshot? scope = requestedStoreId == storeId
                ? new StoreScopeSnapshot(storeId, corporateId, isActive)
                : null;
            return Task.FromResult(scope);
        }
    }
}

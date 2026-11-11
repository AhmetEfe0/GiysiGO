using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Identity.Tests
{
    public sealed class FixtureStoreScopeReader(Guid storeId, Guid corporateId, bool isActive = true,
        Guid? secondStoreId = null, Guid? secondCorporateId = null) : IStoreScopeReader
    {
        public Task<StoreScopeSnapshot?> GetScopeAsync(Guid requestedStoreId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            StoreScopeSnapshot? scope = requestedStoreId == storeId
                ? new StoreScopeSnapshot(storeId, corporateId, isActive)
                : requestedStoreId == secondStoreId && secondCorporateId.HasValue
                    ? new StoreScopeSnapshot(requestedStoreId, secondCorporateId.Value, true)
                    : null;
            return Task.FromResult(scope);
        }
    }
}

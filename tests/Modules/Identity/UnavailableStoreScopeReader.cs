using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Identity.Tests
{
    // Yalnız Identity repository testlerinin DI kurulumu içindir; gerçek kapsam testleri API testlerindedir.
    internal sealed class UnavailableStoreScopeReader : IStoreScopeReader
    {
        public Task<StoreScopeSnapshot?> GetScopeAsync(Guid storeId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => throw new InvalidOperationException("Dükkân kapsamı doğrulaması gerçek Catalog sağlayıcısıyla çalıştırılmalıdır.");
    }
}

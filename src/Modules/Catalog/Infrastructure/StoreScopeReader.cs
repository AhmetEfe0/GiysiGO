using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Catalog.Infrastructure
{
    public sealed class StoreScopeReader : IStoreScopeReader
    {
        public Task<StoreScopeSnapshot?> GetScopeAsync(Guid storeId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            StoreCatalogReader.ValidateTransaction(connection, transaction);
            StoreCatalogReader.ValidateId(storeId);
            return connection.QuerySingleOrDefaultAsync<StoreScopeSnapshot>(new CommandDefinition("catalog.usp_GetStoreScope",
                new { StoreId = storeId }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }
    }
}

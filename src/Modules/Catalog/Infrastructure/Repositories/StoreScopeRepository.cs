using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Infrastructure.Repositories
{
    public sealed class StoreScopeRepository : IStoreScopeReader
    {
        public async Task<StoreScopeSnapshot?> GetScopeAsync(Guid storeId, DbConnection connection,
            DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            if (storeId == Guid.Empty)
            {
                throw new ArgumentException("Store ID cannot be empty.", nameof(storeId));
            }

            if (connection.State != ConnectionState.Open || transaction.Connection != connection)
            {
                throw new InvalidOperationException("An open connection and its transaction are required.");
            }

            var command = new CommandDefinition("catalog.usp_GetStoreById", new { Id = storeId },
                transaction, commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);
            var store = await connection.QuerySingleOrDefaultAsync<Store>(command);
            return store is null ? null : new StoreScopeSnapshot(store.Id, store.CorporateId, store.IsActive);
        }
    }
}

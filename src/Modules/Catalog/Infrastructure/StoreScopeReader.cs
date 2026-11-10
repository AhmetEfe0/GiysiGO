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
            if (storeId == Guid.Empty) throw new ArgumentException("Dükkân kimliği boş olamaz.", nameof(storeId));
            if (connection.State != ConnectionState.Open || transaction.Connection != connection)
                throw new ArgumentException("Açık bağlantı ve ona ait transaction gereklidir.");
            return connection.QuerySingleOrDefaultAsync<StoreScopeSnapshot>(new CommandDefinition(
                "catalog.usp_GetStoreScope", new { StoreId = storeId }, transaction,
                commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }
    }
}

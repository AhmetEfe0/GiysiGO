using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Infrastructure;

namespace GiysiGo.Modules.Catalog.Infrastructure
{
    public sealed class StoreCatalogReader(SqlConnectionFactory connections) : IStoreCatalogReader, ITransactionalStoreCatalogReader
    {
        public async Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId);
            await using var connection = await connections.OpenAsync(cancellationToken);
            return await ReadLocationAsync(storeId, connection, null, cancellationToken);
        }

        public Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateTransaction(connection, transaction);
            return ReadLocationAsync(storeId, connection, transaction, cancellationToken);
        }

        public async Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateId(productTypeId); ValidateId(serviceId);
            await using var connection = await connections.OpenAsync(cancellationToken);
            return await ReadOfferingAsync(storeId, productTypeId, serviceId, connection, null, cancellationToken);
        }

        public Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateId(productTypeId); ValidateId(serviceId); ValidateTransaction(connection, transaction);
            return ReadOfferingAsync(storeId, productTypeId, serviceId, connection, transaction, cancellationToken);
        }

        public async Task<bool> ServesLocationAsync(Guid storeId, decimal latitude, decimal longitude, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateCoordinates(latitude, longitude);
            await using var connection = await connections.OpenAsync(cancellationToken);
            return await ReadCoverageAsync(storeId, latitude, longitude, connection, null, cancellationToken);
        }

        public Task<bool> ServesLocationAsync(Guid storeId, decimal latitude, decimal longitude, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateCoordinates(latitude, longitude); ValidateTransaction(connection, transaction);
            return ReadCoverageAsync(storeId, latitude, longitude, connection, transaction, cancellationToken);
        }

        internal static void ValidateId(Guid id)
        {
            if (id == Guid.Empty) throw new ArgumentException("Kimlik boş olamaz.");
        }

        internal static void ValidateTransaction(DbConnection connection, DbTransaction transaction)
        {
            ArgumentNullException.ThrowIfNull(connection); ArgumentNullException.ThrowIfNull(transaction);
            if (connection.State != ConnectionState.Open || !ReferenceEquals(transaction.Connection, connection))
                throw new ArgumentException("Açık bağlantı ve ona ait etkin transaction gereklidir.");
        }

        private static void ValidateCoordinates(decimal latitude, decimal longitude)
        {
            if (latitude is < -90 or > 90 || longitude is < -180 or > 180)
                throw new ArgumentException("Koordinat geçersiz.");
        }

        private static Task<StoreLocationSnapshot?> ReadLocationAsync(Guid id, DbConnection connection, DbTransaction? transaction, CancellationToken token)
            => connection.QuerySingleOrDefaultAsync<StoreLocationSnapshot>(new CommandDefinition("catalog.usp_GetStoreLocation",
                new { StoreId = id }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        private static Task<StoreOfferingSnapshot?> ReadOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, DbConnection connection, DbTransaction? transaction, CancellationToken token)
            => connection.QuerySingleOrDefaultAsync<StoreOfferingSnapshot>(new CommandDefinition("catalog.usp_GetValidStoreOffering",
                new { StoreId = storeId, ProductTypeId = productTypeId, ServiceId = serviceId }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        private static Task<bool> ReadCoverageAsync(Guid storeId, decimal latitude, decimal longitude, DbConnection connection, DbTransaction? transaction, CancellationToken token)
            => connection.QuerySingleAsync<bool>(new CommandDefinition("catalog.usp_StoreServesLocation",
                new { StoreId = storeId, Latitude = latitude, Longitude = longitude }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
    }
}

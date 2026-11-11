using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;

namespace GiysiGo.Modules.Catalog.Infrastructure
{
    public sealed class StoreCatalogReader(ITransactionRunner transactions, ICorporateStatusReader corporates, IStoreScopeReader scopes) : IStoreCatalogReader, ITransactionalStoreCatalogReader
    {
        public async Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId);
            return await transactions.ExecuteAsync((connection, transaction, token) => ReadLocationAsync(storeId, connection, transaction, token), cancellationToken);
        }

        public Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateTransaction(connection, transaction);
            return ReadLocationAsync(storeId, connection, transaction, cancellationToken);
        }

        public async Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateId(productTypeId); ValidateId(serviceId);
            return await transactions.ExecuteAsync((connection, transaction, token) => ReadOfferingAsync(storeId, productTypeId, serviceId, connection, transaction, token), cancellationToken);
        }

        public async Task<StoreOfferingSnapshot?> GetOfferingByIdAsync(Guid storeId, Guid productTypeId, Guid storeOfferingId, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateId(productTypeId); ValidateId(storeOfferingId);
            return await transactions.ExecuteAsync((connection, transaction, token) => ReadOfferingByIdAsync(storeId, productTypeId, storeOfferingId, connection, transaction, token), cancellationToken);
        }

        public Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateId(productTypeId); ValidateId(serviceId); ValidateTransaction(connection, transaction);
            return ReadOfferingAsync(storeId, productTypeId, serviceId, connection, transaction, cancellationToken);
        }

        public Task<StoreOfferingSnapshot?> GetOfferingByIdAsync(Guid storeId, Guid productTypeId, Guid storeOfferingId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateId(productTypeId); ValidateId(storeOfferingId); ValidateTransaction(connection, transaction);
            return ReadOfferingByIdAsync(storeId, productTypeId, storeOfferingId, connection, transaction, cancellationToken);
        }

        public async Task<bool> ServesLocationAsync(Guid storeId, decimal latitude, decimal longitude, CancellationToken cancellationToken = default)
        {
            ValidateId(storeId); ValidateCoordinates(latitude, longitude);
            return await transactions.ExecuteAsync((connection, transaction, token) => ReadCoverageAsync(storeId, latitude, longitude, connection, transaction, token), cancellationToken);
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

        private async Task<bool> IsActiveAsync(Guid id, DbConnection connection, DbTransaction transaction, CancellationToken token)
        {
            var scope = await scopes.GetScopeAsync(id, connection, transaction, token);
            return scope is { IsActive: true } && await corporates.IsActiveAsync(scope.CorporateId, connection, transaction, token);
        }

        private async Task<StoreLocationSnapshot?> ReadLocationAsync(Guid id, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => !await IsActiveAsync(id, connection, transaction, token) ? null
                : await connection.QuerySingleOrDefaultAsync<StoreLocationSnapshot>(new CommandDefinition("catalog.usp_GetStoreLocation",
                    new { StoreId = id }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        private async Task<StoreOfferingSnapshot?> ReadOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => !await IsActiveAsync(storeId, connection, transaction, token) ? null
                : await connection.QuerySingleOrDefaultAsync<StoreOfferingSnapshot>(new CommandDefinition("catalog.usp_GetValidStoreOffering",
                    new { StoreId = storeId, ProductTypeId = productTypeId, ServiceId = serviceId }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        private async Task<StoreOfferingSnapshot?> ReadOfferingByIdAsync(Guid storeId, Guid productTypeId, Guid storeOfferingId, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => !await IsActiveAsync(storeId, connection, transaction, token) ? null
                : await connection.QuerySingleOrDefaultAsync<StoreOfferingSnapshot>(new CommandDefinition("catalog.usp_GetCartStoreOfferingById",
                    new { StoreId = storeId, ProductTypeId = productTypeId, StoreOfferingId = storeOfferingId }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        private async Task<bool> ReadCoverageAsync(Guid storeId, decimal latitude, decimal longitude, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => await IsActiveAsync(storeId, connection, transaction, token)
                && await connection.QuerySingleAsync<bool>(new CommandDefinition("catalog.usp_StoreServesLocation",
                    new { StoreId = storeId, Latitude = latitude, Longitude = longitude }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
    }
}

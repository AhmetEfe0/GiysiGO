using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Application.Stores;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Infrastructure.Repositories
{
    public sealed class StoreManagementRepository(ITransactionRunner transactions, ICorporateStatusReader corporates) : IStoreManagementRepository
    {
        public async Task<StorePage> GetPageAsync(Guid corporateId, bool includeInactive, int page, int pageSize, CancellationToken cancellationToken)
            => await transactions.ExecuteAsync(async (connection, transaction, token) =>
        {
            if (!await corporates.IsActiveAsync(corporateId, connection, transaction, token)) return new StorePage([], page, pageSize, 0);
            using var results = await connection.QueryMultipleAsync(new CommandDefinition("catalog.usp_GetManagedStores",
                new { CorporateId = corporateId, IncludeInactive = includeInactive, Page = page, PageSize = pageSize }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
            return new StorePage((await results.ReadAsync<Store>()).AsList(), page, pageSize, await results.ReadSingleAsync<long>());
        }, cancellationToken);

        public async Task<Store?> GetAsync(Guid corporateId, Guid id, CancellationToken cancellationToken)
            => await transactions.ExecuteAsync(async (connection, transaction, token) =>
        {
            if (!await corporates.IsActiveAsync(corporateId, connection, transaction, token)) return null;
            return await connection.QuerySingleOrDefaultAsync<Store>(new CommandDefinition("catalog.usp_GetManagedStore",
                new { CorporateId = corporateId, Id = id }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        }, cancellationToken);

        public Task<Guid> SaveAsync(Guid corporateId, Guid id, StoreWriteData data, bool create, CancellationToken cancellationToken)
            => ExecuteAsync(corporateId, new { Operation = create ? "CREATE" : "UPDATE", CorporateId = corporateId, Id = id, data.Name, data.AddressText, data.Latitude, data.Longitude, data.ServiceRadiusKm }, cancellationToken);

        public async Task SetActiveAsync(Guid corporateId, Guid id, bool isActive, CancellationToken cancellationToken)
            => _ = await ExecuteAsync(corporateId, new { Operation = "SET_ACTIVE", CorporateId = corporateId, Id = id, IsActive = isActive }, cancellationToken);

        private Task<Guid> ExecuteAsync(Guid corporateId, object parameters, CancellationToken cancellationToken)
            => transactions.ExecuteAsync(async (connection, transaction, token) =>
        {
            if (!await corporates.IsActiveAsync(corporateId, connection, transaction, token))
                throw new KeyNotFoundException("Aktif şirket bulunamadı.");
            return await connection.QuerySingleAsync<Guid>(new CommandDefinition("catalog.usp_ManageStore", parameters, transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
        }, cancellationToken);
    }
}

using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Application.Stores;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Infrastructure.Repositories
{
    public sealed class StoreManagementRepository(SqlConnectionFactory connections) : IStoreManagementRepository
    {
        public async Task<StorePage> GetPageAsync(Guid corporateId, bool includeInactive, int page, int pageSize, CancellationToken cancellationToken)
        {
            await using var connection = await connections.OpenAsync(cancellationToken);
            using var results = await connection.QueryMultipleAsync(new CommandDefinition("catalog.usp_GetManagedStores",
                new { CorporateId = corporateId, IncludeInactive = includeInactive, Page = page, PageSize = pageSize }, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
            return new StorePage((await results.ReadAsync<Store>()).AsList(), page, pageSize, await results.ReadSingleAsync<long>());
        }

        public async Task<Store?> GetAsync(Guid corporateId, Guid id, CancellationToken cancellationToken)
        {
            await using var connection = await connections.OpenAsync(cancellationToken);
            return await connection.QuerySingleOrDefaultAsync<Store>(new CommandDefinition("catalog.usp_GetManagedStore",
                new { CorporateId = corporateId, Id = id }, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }

        public Task<Guid> SaveAsync(Guid corporateId, Guid id, StoreWriteData data, bool create, CancellationToken cancellationToken)
            => ExecuteAsync(new { Operation = create ? "CREATE" : "UPDATE", CorporateId = corporateId, Id = id, data.Name, data.AddressText, data.Latitude, data.Longitude, data.ServiceRadiusKm }, cancellationToken);

        public async Task SetActiveAsync(Guid corporateId, Guid id, bool isActive, CancellationToken cancellationToken)
            => _ = await ExecuteAsync(new { Operation = "SET_ACTIVE", CorporateId = corporateId, Id = id, IsActive = isActive }, cancellationToken);

        private async Task<Guid> ExecuteAsync(object parameters, CancellationToken token)
        {
            await using var connection = await connections.OpenAsync(token);
            return await connection.QuerySingleAsync<Guid>(new CommandDefinition("catalog.usp_ManageStore", parameters, commandType: CommandType.StoredProcedure, cancellationToken: token));
        }
    }
}

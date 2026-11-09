using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Infrastructure.Repositories
{

    public sealed class CatalogRepository : ICatalogRepository
    {
        private readonly SqlConnectionFactory _sqlConnectionFactory;

        public CatalogRepository(SqlConnectionFactory sqlConnectionFactory)
        {
            _sqlConnectionFactory = sqlConnectionFactory;
        }

        public async Task<IReadOnlyList<ProductCategory>> GetCategoriesAsync(bool includeInactive = false, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@IncludeInactive", includeInactive, DbType.Boolean);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetCategories",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            var result = await connection.QueryAsync<ProductCategory>(command);
            return result.AsList();
        }

        public async Task<ProductCategory?> GetCategoryByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@Id", id, DbType.Guid);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetCategoryById",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            return await connection.QuerySingleOrDefaultAsync<ProductCategory>(command);
        }

        public async Task<IReadOnlyList<ProductType>> GetProductTypesAsync(Guid? categoryId = null, bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@category_id", categoryId, DbType.Guid);
            parameters.Add("@include_inactive", includeInactive, DbType.Boolean);
            parameters.Add("@page_number", pageNumber, DbType.Int32);
            parameters.Add("@page_size", pageSize, DbType.Int32);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetProductTypesPaged",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            var result = await connection.QueryAsync<ProductType>(command);
            return result.AsList();
        }

        public async Task<ProductType?> GetProductTypeByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@Id", id, DbType.Guid);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetProductTypeById",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            return await connection.QuerySingleOrDefaultAsync<ProductType>(command);
        }

        public async Task<IReadOnlyList<ProductType>> GetProductTypesPagedAsync(Guid? categoryId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        {
            return await GetProductTypesAsync(categoryId, pageNumber: pageNumber, pageSize: pageSize, cancellationToken: cancellationToken);
        }

        public async Task<ProductTypePage> GetProductTypePageAsync(Guid? categoryId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);
            using var results = await connection.QueryMultipleAsync(new CommandDefinition(
                "catalog.usp_GetProductTypesPaged",
                new { category_id = categoryId, include_inactive = false, page_number = pageNumber, page_size = pageSize },
                commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
            var items = (await results.ReadAsync<ProductType>()).AsList();
            var totalCount = await results.ReadSingleAsync<int>();
            return new ProductTypePage(items, totalCount);
        }

        public async Task<IReadOnlyList<Service>> GetServicesAsync(bool includeInactive = false, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@IncludeInactive", includeInactive, DbType.Boolean);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetServices",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            var result = await connection.QueryAsync<Service>(command);
            return result.AsList();
        }

        public async Task<Service?> GetServiceByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@Id", id, DbType.Guid);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetServiceById",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            return await connection.QuerySingleOrDefaultAsync<Service>(command);
        }

        public async Task<IReadOnlyList<Store>> GetStoresAsync(bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@include_inactive", includeInactive, DbType.Boolean);
            parameters.Add("@page_number", pageNumber, DbType.Int32);
            parameters.Add("@page_size", pageSize, DbType.Int32);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetStores",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            var result = await connection.QueryAsync<Store>(command);
            return result.AsList();
        }

        public async Task<Store?> GetStoreByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@Id", id, DbType.Guid);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetStoreById",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            return await connection.QuerySingleOrDefaultAsync<Store>(command);
        }

        public async Task<IReadOnlyList<StoreOffering>> GetStoreOfferingsAsync(Guid? storeId = null, Guid? productTypeServiceId = null, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@store_id", storeId, DbType.Guid);
            parameters.Add("@product_type_service_id", productTypeServiceId, DbType.Guid);
            parameters.Add("@include_inactive", false, DbType.Boolean);
            parameters.Add("@page_number", pageNumber, DbType.Int32);
            parameters.Add("@page_size", pageSize, DbType.Int32);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetStoreOfferings",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            var result = await connection.QueryAsync<StoreOffering>(command);
            return result.AsList();
        }

        public async Task<StoreOffering?> GetStoreOfferingByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var parameters = new DynamicParameters();
            parameters.Add("@Id", id, DbType.Guid);

            var command = new CommandDefinition(
                commandText: "catalog.usp_GetStoreOfferingById",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            return await connection.QuerySingleOrDefaultAsync<StoreOffering>(command);
        }

        public async Task<IReadOnlyList<ProductTypeService>> GetProductTypeServicesAsync(Guid? productTypeId = null, Guid? serviceId = null, bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);
            var parameters = new DynamicParameters();
            parameters.Add("@ProductTypeId", productTypeId, DbType.Guid);
            parameters.Add("@ServiceId", serviceId, DbType.Guid);
            parameters.Add("@IncludeInactive", includeInactive, DbType.Boolean);
            parameters.Add("@page_number", pageNumber, DbType.Int32);
            parameters.Add("@page_size", pageSize, DbType.Int32);
            var command = new CommandDefinition("catalog.usp_GetProductTypeServices", parameters, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken);
            return (await connection.QueryAsync<ProductTypeService>(command)).AsList();
        }

        public async Task<ProductTypeService?> GetProductTypeServiceByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);
            var command = new CommandDefinition("catalog.usp_GetProductTypeServiceById", new { Id = id }, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken);
            return await connection.QuerySingleOrDefaultAsync<ProductTypeService>(command);
        }

        public async Task<Guid> AddProductTypeServiceAsync(ProductTypeService entity, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);
            var command = new CommandDefinition("catalog.usp_InsertProductTypeService", new
            {
                Id = entity.Id == Guid.Empty ? (Guid?)null : entity.Id,
                entity.ProductTypeId,
                entity.ServiceId,
                entity.DefaultPrice,
                entity.Currency,
                entity.PriceUnit,
                entity.SelectionKind,
                entity.IsDefaultSelected,
                entity.IsActive
            }, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken);
            return await connection.QuerySingleAsync<Guid>(command);
        }

        public async Task UpdateProductTypeServiceAsync(ProductTypeService entity, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);
            var command = new CommandDefinition("catalog.usp_UpdateProductTypeService", new
            {
                entity.Id,
                entity.ProductTypeId,
                entity.ServiceId,
                entity.DefaultPrice,
                entity.Currency,
                entity.PriceUnit,
                entity.SelectionKind,
                entity.IsDefaultSelected,
                entity.IsActive
            }, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken);
            await connection.ExecuteAsync(command);
        }

        public async Task DeleteProductTypeServiceAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);
            var command = new CommandDefinition("catalog.usp_DeleteProductTypeService", new { Id = id }, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken);
            await connection.ExecuteAsync(command);
        }
        public async Task<Guid> AddCategoryAsync(string code, string name, int sortOrder = 0, CancellationToken cancellationToken = default)
        {
            await using var connection = await _sqlConnectionFactory.OpenAsync(cancellationToken);

            var id = Guid.NewGuid();
            var parameters = new DynamicParameters();
            parameters.Add("@id", id, DbType.Guid);
            parameters.Add("@code", code, DbType.String);
            parameters.Add("@name", name, DbType.String);
            parameters.Add("@sort_order", sortOrder, DbType.Int32);
            parameters.Add("@is_active", true, DbType.Boolean);

            var command = new CommandDefinition(
                commandText: "catalog.usp_InsertCategory",
                parameters: parameters,
                commandType: CommandType.StoredProcedure,
                cancellationToken: cancellationToken);

            return await connection.ExecuteScalarAsync<Guid>(command);
        }
    }
}

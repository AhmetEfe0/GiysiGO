using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Infrastructure.Repositories
{
    public sealed class CatalogManagementRepository(SqlConnectionFactory connections) : ICatalogManagementRepository
    {
        public Task<Guid> SaveCategoryAsync(ProductCategory category, bool create, CancellationToken cancellationToken = default)
            => ExecuteAsync("catalog.usp_ManageCategory", new { Operation = create ? "CREATE" : "UPDATE", category.Id, category.Code, category.Name, category.SortOrder, category.IsActive }, cancellationToken);
        public async Task DeleteCategoryAsync(Guid id, CancellationToken cancellationToken = default)
            => _ = await ExecuteAsync("catalog.usp_ManageCategory", new { Operation = "DELETE", Id = id }, cancellationToken);
        public Task<Guid> SaveProductTypeAsync(ProductType product, bool create, CancellationToken cancellationToken = default)
            => ExecuteAsync("catalog.usp_ManageProductType", new { Operation = create ? "CREATE" : "UPDATE", product.Id, product.CategoryId, product.Code, product.Name, product.BaseUnit, product.IsActive }, cancellationToken);
        public async Task DeleteProductTypeAsync(Guid id, CancellationToken cancellationToken = default)
            => _ = await ExecuteAsync("catalog.usp_ManageProductType", new { Operation = "DELETE", Id = id }, cancellationToken);
        public Task<Guid> SaveServiceAsync(Service service, bool create, CancellationToken cancellationToken = default)
            => ExecuteAsync("catalog.usp_ManageService", new { Operation = create ? "CREATE" : "UPDATE", service.Id, service.Code, service.Name, service.IsActive }, cancellationToken);
        public async Task DeleteServiceAsync(Guid id, CancellationToken cancellationToken = default)
            => _ = await ExecuteAsync("catalog.usp_ManageService", new { Operation = "DELETE", Id = id }, cancellationToken);
        public Task<Guid> SaveProductTypeServiceAsync(ProductTypeService pair, bool create, CancellationToken cancellationToken = default)
            => ExecuteAsync("catalog.usp_ManageProductTypeService", new { Operation = create ? "CREATE" : "UPDATE", pair.Id, pair.ProductTypeId, pair.ServiceId, pair.DefaultPrice, pair.PriceUnit, pair.SelectionKind, pair.IsActive }, cancellationToken);
        public async Task DeleteProductTypeServiceAsync(Guid id, CancellationToken cancellationToken = default)
            => _ = await ExecuteAsync("catalog.usp_ManageProductTypeService", new { Operation = "DELETE", Id = id }, cancellationToken);

        private async Task<Guid> ExecuteAsync(string procedure, object parameters, CancellationToken cancellationToken)
        {
            await using var connection = await connections.OpenAsync(cancellationToken);
            return await connection.QuerySingleAsync<Guid>(new CommandDefinition(procedure, parameters,
                commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }
    }
}

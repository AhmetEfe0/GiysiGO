using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Application.Repositories
{
    public interface ICatalogManagementRepository
    {
        Task<Guid> SaveCategoryAsync(ProductCategory category, bool create, CancellationToken cancellationToken = default);
        Task DeleteCategoryAsync(Guid id, CancellationToken cancellationToken = default);
        Task<Guid> SaveProductTypeAsync(ProductType product, bool create, CancellationToken cancellationToken = default);
        Task DeleteProductTypeAsync(Guid id, CancellationToken cancellationToken = default);
        Task<Guid> SaveServiceAsync(Service service, bool create, CancellationToken cancellationToken = default);
        Task DeleteServiceAsync(Guid id, CancellationToken cancellationToken = default);
        Task<Guid> SaveProductTypeServiceAsync(ProductTypeService pair, bool create, CancellationToken cancellationToken = default);
        Task DeleteProductTypeServiceAsync(Guid id, CancellationToken cancellationToken = default);
    }
}

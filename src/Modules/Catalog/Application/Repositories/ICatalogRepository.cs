using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Application.Repositories
{

    public interface ICatalogRepository
    {
        Task<IReadOnlyList<ProductCategory>> GetCategoriesAsync(bool includeInactive = false, CancellationToken cancellationToken = default);
        Task<ProductCategory?> GetCategoryByIdAsync(Guid id, CancellationToken cancellationToken = default);

        Task<IReadOnlyList<ProductType>> GetProductTypesAsync(Guid? categoryId = null, bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default);
        Task<ProductType?> GetProductTypeByIdAsync(Guid id, CancellationToken cancellationToken = default);

        Task<IReadOnlyList<ProductType>> GetProductTypesPagedAsync(Guid? categoryId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
        Task<ProductTypePage> GetProductTypePageAsync(Guid? categoryId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);

        Task<IReadOnlyList<Service>> GetServicesAsync(bool includeInactive = false, CancellationToken cancellationToken = default);
        Task<Service?> GetServiceByIdAsync(Guid id, CancellationToken cancellationToken = default);

        Task<IReadOnlyList<Store>> GetStoresAsync(bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default);
        Task<Store?> GetStoreByIdAsync(Guid id, CancellationToken cancellationToken = default);

        Task<IReadOnlyList<StoreOffering>> GetStoreOfferingsAsync(Guid? storeId = null, Guid? productTypeServiceId = null, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default);
        Task<StoreOffering?> GetStoreOfferingByIdAsync(Guid id, CancellationToken cancellationToken = default);
        Task<IReadOnlyList<ProductTypeService>> GetProductTypeServicesAsync(Guid? productTypeId = null, Guid? serviceId = null, bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default);
        Task<ProductTypeService?> GetProductTypeServiceByIdAsync(Guid id, CancellationToken cancellationToken = default);
        Task<Guid> AddProductTypeServiceAsync(ProductTypeService entity, CancellationToken cancellationToken = default);
        Task UpdateProductTypeServiceAsync(ProductTypeService entity, CancellationToken cancellationToken = default);
        Task DeleteProductTypeServiceAsync(Guid id, CancellationToken cancellationToken = default);

        Task<Guid> AddCategoryAsync(string code, string name, int sortOrder = 0, CancellationToken cancellationToken = default);
    }
}

using GiysiGo.API.Controllers.Catalog;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Domain;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.IntegrationTests
{

    public sealed class CatalogControllerTests
    {
        [Fact]
        public async Task Product_services_are_returned_as_dtos_with_no_initial_selection()
        {
            var repository = new FakeCatalogRepository();
            var controller = new CatalogController(repository);

            var result = await controller.GetProductTypeServices(repository.ProductTypeId, CancellationToken.None);

            var response = Assert.IsType<CatalogProductServicesDto>(Assert.IsType<OkObjectResult>(result.Result).Value);
            Assert.Equal("none", response.InitialSelection);
            Assert.Equal(1, response.MinimumPrimarySelections);
            Assert.False(response.AddOnsCountTowardMinimum);
            Assert.Equal(2, response.Services.Count);
            Assert.All(response.Services, option => Assert.False(option.IsSelectedByDefault));
            Assert.DoesNotContain(response.Services, option => option.ServiceId == repository.InactiveServiceId);
        }

        [Fact]
        public async Task Services_for_missing_or_inactive_product_types_return_not_found()
        {
            var repository = new FakeCatalogRepository { ProductType = null };
            var controller = new CatalogController(repository);

            var result = await controller.GetProductTypeServices(repository.ProductTypeId, CancellationToken.None);

            Assert.IsType<NotFoundResult>(result.Result);
        }

        [Fact]
        public async Task Product_services_include_every_page_of_valid_combinations()
        {
            var repository = new FakeCatalogRepository
            {
                ExtraServices = Enumerable.Range(1, 125).Select(index => new Service
                {
                    Id = Guid.NewGuid(), Code = $"EXTRA-{index}", Name = "Ek test hizmeti", IsActive = true
                }).ToArray()
            };
            var result = await new CatalogController(repository).GetProductTypeServices(repository.ProductTypeId, CancellationToken.None);
            var response = Assert.IsType<CatalogProductServicesDto>(Assert.IsType<OkObjectResult>(result.Result).Value);
            Assert.Equal(127, response.Services.Count);
            Assert.Equal(127, response.Services.Select(option => option.ServiceId).Distinct().Count());
        }

        [Theory]
        [InlineData(false)]
        [InlineData(true)]
        public async Task Product_and_services_are_hidden_when_category_is_missing_or_inactive(bool missing)
        {
            var repository = new FakeCatalogRepository { Category = missing ? null : new ProductCategory { IsActive = false } };
            var controller = new CatalogController(repository);
            Assert.IsType<NotFoundResult>((await controller.GetProductTypeById(repository.ProductTypeId, CancellationToken.None)).Result);
            Assert.IsType<NotFoundResult>((await controller.GetProductTypeServices(repository.ProductTypeId, CancellationToken.None)).Result);
        }

        internal sealed class FakeCatalogRepository : ICatalogRepository
        {
            public bool FailCategoryReads { get; init; }
            public ProductCategory? Category { get; set; } = new() { Id = Guid.NewGuid(), IsActive = true };
            public IReadOnlyList<Service> ExtraServices { get; init; } = [];
            public Guid ProductTypeId { get; } = Guid.NewGuid();
            public Guid FirstServiceId { get; } = Guid.NewGuid();
            public Guid SecondServiceId { get; } = Guid.NewGuid();
            public Guid InactiveServiceId { get; } = Guid.NewGuid();
            public ProductType? ProductType { get; set; } = new() { Id = Guid.NewGuid(), IsActive = true };

            public Task<IReadOnlyList<ProductCategory>> GetCategoriesAsync(bool includeInactive = false, CancellationToken cancellationToken = default)
                => FailCategoryReads ? throw new InvalidOperationException("gizli-teknik-ayrinti") : Task.FromResult<IReadOnlyList<ProductCategory>>([]);

            public Task<ProductCategory?> GetCategoryByIdAsync(Guid id, CancellationToken cancellationToken = default)
                => Task.FromResult(Category);

            public Task<IReadOnlyList<ProductType>> GetProductTypesAsync(Guid? categoryId = null, bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
                => Task.FromResult<IReadOnlyList<ProductType>>([]);

            public Task<ProductType?> GetProductTypeByIdAsync(Guid id, CancellationToken cancellationToken = default)
            {
                if (ProductType is not null) ProductType.Id = ProductTypeId;
                return Task.FromResult(ProductType);
            }

            public Task<IReadOnlyList<ProductType>> GetProductTypesPagedAsync(Guid? categoryId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
                => Task.FromResult<IReadOnlyList<ProductType>>([]);

            public Task<ProductTypePage> GetProductTypePageAsync(Guid? categoryId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
                => Task.FromResult(new ProductTypePage([], 0));

            public Task<IReadOnlyList<Service>> GetServicesAsync(bool includeInactive = false, CancellationToken cancellationToken = default)
                => Task.FromResult<IReadOnlyList<Service>>(new Service[] {
                    new Service { Id = FirstServiceId, Code = "S001", Name = "Kuru Temizleme", IsActive = true },
                    new Service { Id = SecondServiceId, Code = "S002", Name = "Ütü", IsActive = true },
                    new Service { Id = InactiveServiceId, Code = "S003", Name = "Pasif", IsActive = false }
                }.Concat(ExtraServices).ToArray());

            public Task<Service?> GetServiceByIdAsync(Guid id, CancellationToken cancellationToken = default)
                => Task.FromResult<Service?>(null);

            public Task<IReadOnlyList<Store>> GetStoresAsync(bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
                => Task.FromResult<IReadOnlyList<Store>>([]);

            public Task<Store?> GetStoreByIdAsync(Guid id, CancellationToken cancellationToken = default)
                => Task.FromResult<Store?>(null);

            public Task<IReadOnlyList<StoreOffering>> GetStoreOfferingsAsync(Guid? storeId = null, Guid? productTypeServiceId = null, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
                => Task.FromResult<IReadOnlyList<StoreOffering>>([]);

            public Task<StoreOffering?> GetStoreOfferingByIdAsync(Guid id, CancellationToken cancellationToken = default)
                => Task.FromResult<StoreOffering?>(null);

            public Task<IReadOnlyList<ProductTypeService>> GetProductTypeServicesAsync(Guid? productTypeId = null, Guid? serviceId = null, bool includeInactive = false, int pageNumber = 1, int pageSize = 50, CancellationToken cancellationToken = default)
            {
                return Task.FromResult<IReadOnlyList<ProductTypeService>>(new ProductTypeService[] {
                    new ProductTypeService { Id = Guid.NewGuid(), ProductTypeId = ProductTypeId, ServiceId = FirstServiceId, DefaultPrice = 200, Currency = "TRY", PriceUnit = "PIECE", SelectionKind = "BASE", IsDefaultSelected = true, IsActive = true },
                    new ProductTypeService { Id = Guid.NewGuid(), ProductTypeId = ProductTypeId, ServiceId = SecondServiceId, DefaultPrice = 100, Currency = "TRY", PriceUnit = "PIECE", SelectionKind = "ADD_ON", IsDefaultSelected = false, IsActive = true },
                    new ProductTypeService { Id = Guid.NewGuid(), ProductTypeId = ProductTypeId, ServiceId = InactiveServiceId, DefaultPrice = 50, Currency = "TRY", PriceUnit = "PIECE", SelectionKind = "ADD_ON", IsActive = true }
                }.Concat(ExtraServices.Select(service => new ProductTypeService { Id = Guid.NewGuid(), ProductTypeId = ProductTypeId, ServiceId = service.Id, DefaultPrice = 10, Currency = "TRY", PriceUnit = "PIECE", SelectionKind = "BASE", IsActive = true }))
                    .Skip((pageNumber - 1) * pageSize).Take(pageSize).ToArray());
            }

            public Task<ProductTypeService?> GetProductTypeServiceByIdAsync(Guid id, CancellationToken cancellationToken = default)
                => Task.FromResult<ProductTypeService?>(null);

            public Task<Guid> AddProductTypeServiceAsync(ProductTypeService entity, CancellationToken cancellationToken = default)
                => throw new NotSupportedException();

            public Task UpdateProductTypeServiceAsync(ProductTypeService entity, CancellationToken cancellationToken = default)
                => throw new NotSupportedException();

            public Task DeleteProductTypeServiceAsync(Guid id, CancellationToken cancellationToken = default)
                => throw new NotSupportedException();

            public Task<Guid> AddCategoryAsync(string code, string name, int sortOrder = 0, CancellationToken cancellationToken = default)
                => throw new NotSupportedException();
        }
    }
}

using GiysiGo.Modules.Catalog.Application.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers.Catalog
{

    [ApiController]
    [AllowAnonymous]
    [Route("catalog")]
    public sealed class CatalogController(ICatalogRepository catalogRepository) : ControllerBase
    {
        [HttpGet("categories/{id:guid}")]
        public async Task<ActionResult<CatalogCategoryDto>> GetCategoryById(Guid id, CancellationToken cancellationToken)
        {
            var category = await catalogRepository.GetCategoryByIdAsync(id, cancellationToken);
            if (category is null || !category.IsActive) return NotFound();
            return Ok(new CatalogCategoryDto(category.Id, category.Code, category.Name, category.SortOrder));
        }

        [HttpGet("product-types/{id:guid}")]
        public async Task<ActionResult<CatalogProductTypeDto>> GetProductTypeById(Guid id, CancellationToken cancellationToken)
        {
            var product = await catalogRepository.GetProductTypeByIdAsync(id, cancellationToken);
            if (product is null || !product.IsActive) return NotFound();
            var category = await catalogRepository.GetCategoryByIdAsync(product.CategoryId, cancellationToken);
            if (category is null || !category.IsActive) return NotFound();
            return Ok(new CatalogProductTypeDto(product.Id, product.CategoryId, product.Code, product.Name, product.BaseUnit));
        }

        [HttpGet("services/{id:guid}")]
        public async Task<ActionResult<CatalogServiceDto>> GetServiceById(Guid id, CancellationToken cancellationToken)
        {
            var service = await catalogRepository.GetServiceByIdAsync(id, cancellationToken);
            if (service is null || !service.IsActive) return NotFound();
            return Ok(new CatalogServiceDto(service.Id, service.Code, service.Name));
        }

        [HttpGet("categories")]
        public async Task<ActionResult<IReadOnlyList<CatalogCategoryDto>>> GetCategories(CancellationToken cancellationToken)
        {
            var categories = await catalogRepository.GetCategoriesAsync(cancellationToken: cancellationToken);
            return Ok(categories.Select(category => new CatalogCategoryDto(
                category.Id,
                category.Code,
                category.Name,
                category.SortOrder)).ToArray());
        }

        [HttpGet("product-types")]
        public async Task<ActionResult<IReadOnlyList<CatalogProductTypeDto>>> GetProductTypes(
            [FromQuery] Guid? categoryId,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 50,
            CancellationToken cancellationToken = default)
        {
            if (pageNumber < 1 || pageSize is < 1 or > 100)
                return BadRequest(new ProblemDetails
                {
                    Title = "Geçersiz sayfalama parametreleri.",
                    Detail = "pageNumber pozitif, pageSize ise 1 ile 100 arasında olmalıdır."
                });

            var productTypes = await catalogRepository.GetProductTypesPagedAsync(
                categoryId,
                pageNumber,
                pageSize,
                cancellationToken);

            return Ok(productTypes.Select(productType => new CatalogProductTypeDto(
                productType.Id,
                productType.CategoryId,
                productType.Code,
                productType.Name,
                productType.BaseUnit)).ToArray());
        }

        [HttpGet("product-types/{productTypeId:guid}/services")]
        public async Task<ActionResult<CatalogProductServicesDto>> GetProductTypeServices(
            Guid productTypeId,
            CancellationToken cancellationToken)
        {
            var productType = await catalogRepository.GetProductTypeByIdAsync(productTypeId, cancellationToken);
            if (productType is null || !productType.IsActive) return NotFound();
            var category = await catalogRepository.GetCategoryByIdAsync(productType.CategoryId, cancellationToken);
            if (category is null || !category.IsActive) return NotFound();

            var productTypeServices = new List<GiysiGo.Modules.Catalog.Domain.ProductTypeService>();
            for (var page = 1; ; page++)
            {
                var batch = await catalogRepository.GetProductTypeServicesAsync(
                    productTypeId: productTypeId, includeInactive: false,
                    pageNumber: page, pageSize: 100, cancellationToken: cancellationToken);
                productTypeServices.AddRange(batch);
                if (batch.Count < 100) break;
            }
            var services = await catalogRepository.GetServicesAsync(cancellationToken: cancellationToken);
            var serviceById = services
                .Where(service => service.IsActive)
                .ToDictionary(service => service.Id);

            var options = productTypeServices
                .Where(productTypeService => productTypeService.IsActive
                    && serviceById.ContainsKey(productTypeService.ServiceId))
                .Select(productTypeService =>
                {
                    var service = serviceById[productTypeService.ServiceId];
                    return new CatalogServiceOptionDto(
                        productTypeService.Id,
                        service.Id,
                        service.Code,
                        service.Name,
                        productTypeService.DefaultPrice,
                        productTypeService.Currency,
                        productTypeService.PriceUnit,
                        productTypeService.SelectionKind,
                        IsSelectedByDefault: false);
                })
                .ToArray();

            return Ok(new CatalogProductServicesDto(
                productType.Id,
                InitialSelection: "none",
                MinimumPrimarySelections: 1,
                AddOnsCountTowardMinimum: false,
                options));
        }
    }
}

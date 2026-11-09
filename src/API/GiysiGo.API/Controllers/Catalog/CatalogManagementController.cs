using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers.Catalog
{
    [ApiController]
    [Route("catalog")]
    [Authorize(Policy = PermissionCodes.CatalogManage)]
    [TypeFilter(typeof(CatalogWriteExceptionFilter))]
    public sealed class CatalogManagementController(ICatalogManagementRepository catalog) : ControllerBase
    {
        [HttpPost("categories")]
        public async Task<ActionResult<CatalogWriteResult>> CreateCategory(CatalogCategoryWriteRequest request, CancellationToken cancellationToken)
        {
            var id = await catalog.SaveCategoryAsync(new ProductCategory { Id = Guid.NewGuid(), Code = request.Code, Name = request.Name, SortOrder = request.SortOrder, IsActive = request.IsActive }, true, cancellationToken);
            return Created($"/catalog/categories/{id}", new CatalogWriteResult(id));
        }

        [HttpPut("categories/{id:guid}")]
        public async Task<IActionResult> UpdateCategory(Guid id, CatalogCategoryWriteRequest request, CancellationToken cancellationToken)
        {
            await catalog.SaveCategoryAsync(new ProductCategory { Id = id, Code = request.Code, Name = request.Name, SortOrder = request.SortOrder, IsActive = request.IsActive }, false, cancellationToken);
            return NoContent();
        }

        [HttpDelete("categories/{id:guid}")]
        public async Task<IActionResult> DeleteCategory(Guid id, CancellationToken cancellationToken)
        {
            await catalog.DeleteCategoryAsync(id, cancellationToken);
            return NoContent();
        }

        [HttpPost("product-types")]
        public async Task<ActionResult<CatalogWriteResult>> CreateProductType(CatalogProductTypeWriteRequest request, CancellationToken cancellationToken)
        {
            var id = await catalog.SaveProductTypeAsync(new ProductType { Id = Guid.NewGuid(), CategoryId = request.CategoryId, Code = request.Code, Name = request.Name, BaseUnit = request.BaseUnit, IsActive = request.IsActive }, true, cancellationToken);
            return Created($"/catalog/product-types/{id}", new CatalogWriteResult(id));
        }

        [HttpPut("product-types/{id:guid}")]
        public async Task<IActionResult> UpdateProductType(Guid id, CatalogProductTypeWriteRequest request, CancellationToken cancellationToken)
        {
            await catalog.SaveProductTypeAsync(new ProductType { Id = id, CategoryId = request.CategoryId, Code = request.Code, Name = request.Name, BaseUnit = request.BaseUnit, IsActive = request.IsActive }, false, cancellationToken);
            return NoContent();
        }

        [HttpDelete("product-types/{id:guid}")]
        public async Task<IActionResult> DeleteProductType(Guid id, CancellationToken cancellationToken)
        {
            await catalog.DeleteProductTypeAsync(id, cancellationToken);
            return NoContent();
        }

        [HttpPost("services")]
        public async Task<ActionResult<CatalogWriteResult>> CreateService(CatalogServiceWriteRequest request, CancellationToken cancellationToken)
        {
            var id = await catalog.SaveServiceAsync(new Service { Id = Guid.NewGuid(), Code = request.Code, Name = request.Name, IsActive = request.IsActive }, true, cancellationToken);
            return Created($"/catalog/services/{id}", new CatalogWriteResult(id));
        }

        [HttpPut("services/{id:guid}")]
        public async Task<IActionResult> UpdateService(Guid id, CatalogServiceWriteRequest request, CancellationToken cancellationToken)
        {
            await catalog.SaveServiceAsync(new Service { Id = id, Code = request.Code, Name = request.Name, IsActive = request.IsActive }, false, cancellationToken);
            return NoContent();
        }

        [HttpDelete("services/{id:guid}")]
        public async Task<IActionResult> DeleteService(Guid id, CancellationToken cancellationToken)
        {
            await catalog.DeleteServiceAsync(id, cancellationToken);
            return NoContent();
        }

        [HttpPost("product-type-services")]
        public async Task<ActionResult<CatalogWriteResult>> CreateProductTypeService(CatalogProductTypeServiceWriteRequest request, CancellationToken cancellationToken)
        {
            var id = await catalog.SaveProductTypeServiceAsync(ToPair(Guid.NewGuid(), request), true, cancellationToken);
            return Created($"/catalog/product-types/{request.ProductTypeId}/services", new CatalogWriteResult(id));
        }

        [HttpPut("product-type-services/{id:guid}")]
        public async Task<IActionResult> UpdateProductTypeService(Guid id, CatalogProductTypeServiceWriteRequest request, CancellationToken cancellationToken)
        {
            await catalog.SaveProductTypeServiceAsync(ToPair(id, request), false, cancellationToken);
            return NoContent();
        }

        [HttpDelete("product-type-services/{id:guid}")]
        public async Task<IActionResult> DeleteProductTypeService(Guid id, CancellationToken cancellationToken)
        {
            await catalog.DeleteProductTypeServiceAsync(id, cancellationToken);
            return NoContent();
        }

        private static ProductTypeService ToPair(Guid id, CatalogProductTypeServiceWriteRequest request)
            => new() { Id = id, ProductTypeId = request.ProductTypeId, ServiceId = request.ServiceId, DefaultPrice = request.DefaultPrice, PriceUnit = request.PriceUnit, SelectionKind = request.SelectionKind, IsDefaultSelected = false, Currency = "TRY", IsActive = request.IsActive };
    }
}

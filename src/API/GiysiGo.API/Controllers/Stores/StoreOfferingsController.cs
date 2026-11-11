using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Offerings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers.Stores
{
    [ApiController, Authorize(Policy = PermissionCodes.StoreOfferingManage)]
    [Route("corporates/{corporateId:guid}/stores/{storeId:guid}/offerings")]
    [TypeFilter(typeof(StoreExceptionFilter))]
    public sealed class StoreOfferingsController(StoreOfferingManagementService offerings) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<ManagedOfferingPage>> List(Guid corporateId, Guid storeId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
            => Ok(await offerings.ListAsync(corporateId, storeId, page, pageSize, cancellationToken));

        [HttpPut("{combinationId:guid}")]
        public async Task<IActionResult> Save(Guid corporateId, Guid storeId, Guid combinationId, OfferingWriteRequest request, CancellationToken cancellationToken)
        {
            await offerings.SaveAsync(corporateId, storeId, combinationId, request.IsActive, request.PriceOverride, cancellationToken);
            return NoContent();
        }

        [HttpPatch("{combinationId:guid}/active")]
        public async Task<IActionResult> SetActive(Guid corporateId, Guid storeId, Guid combinationId, StoreActiveRequest request, CancellationToken cancellationToken)
        {
            await offerings.SetActiveAsync(corporateId, storeId, combinationId, request.IsActive, cancellationToken);
            return NoContent();
        }

        [HttpPatch("{combinationId:guid}/price")]
        public async Task<IActionResult> SetPrice(Guid corporateId, Guid storeId, Guid combinationId, OfferingPriceRequest request, CancellationToken cancellationToken)
        {
            await offerings.SetPriceAsync(corporateId, storeId, combinationId, request.PriceOverride, cancellationToken);
            return NoContent();
        }
    }
}

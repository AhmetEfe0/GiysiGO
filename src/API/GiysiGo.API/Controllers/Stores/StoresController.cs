using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Stores;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers.Stores
{
    [ApiController, Authorize, Route("corporates/{corporateId:guid}/stores"), TypeFilter(typeof(StoreExceptionFilter))]
    public sealed class StoresController(StoreManagementService stores) : ControllerBase
    {
        [HttpGet, Authorize(Policy = PermissionCodes.StoreView)]
        public async Task<ActionResult<StorePageDto>> List(Guid corporateId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] bool includeInactive = false, CancellationToken cancellationToken = default)
        {
            var result = await stores.GetPageAsync(corporateId, includeInactive, page, pageSize, cancellationToken);
            return Ok(new StorePageDto(result.Items.Select(StoreDto.From).ToArray(), result.Page, result.PageSize, result.TotalCount));
        }

        [HttpGet("{id:guid}")]
        public async Task<ActionResult<StoreDto>> Get(Guid corporateId, Guid id, CancellationToken cancellationToken)
            => Ok(StoreDto.From(await stores.GetAsync(corporateId, id, cancellationToken)));

        [HttpPost, Authorize(Policy = PermissionCodes.StoreManage)]
        public async Task<ActionResult<StoreCreatedDto>> Create(Guid corporateId, StoreWriteRequest request, CancellationToken cancellationToken)
        {
            var id = await stores.CreateAsync(corporateId, request.ToData(), cancellationToken);
            return CreatedAtAction(nameof(Get), new { corporateId, id }, new StoreCreatedDto(id));
        }

        [HttpPut("{id:guid}"), Authorize(Policy = PermissionCodes.StoreManage)]
        public async Task<IActionResult> Update(Guid corporateId, Guid id, StoreWriteRequest request, CancellationToken cancellationToken)
        {
            await stores.UpdateAsync(corporateId, id, request.ToData(), cancellationToken);
            return NoContent();
        }

        [HttpPatch("{id:guid}/active"), Authorize(Policy = PermissionCodes.StoreManage)]
        public async Task<IActionResult> SetActive(Guid corporateId, Guid id, StoreActiveRequest request, CancellationToken cancellationToken)
        {
            await stores.SetActiveAsync(corporateId, id, request.IsActive, cancellationToken);
            return NoContent();
        }
    }
}

using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.IntegrationTests
{
    [ApiController]
    [Route("test/permissions")]
    public sealed class TestPermissionController : ControllerBase
    {
        [HttpGet("corporates/{corporateId:guid}/stores/{storeId:guid}")]
        [Authorize(Policy = PermissionCodes.StoreView)]
        public IActionResult ReadStore(Guid corporateId, Guid storeId) => Ok();
    }
}

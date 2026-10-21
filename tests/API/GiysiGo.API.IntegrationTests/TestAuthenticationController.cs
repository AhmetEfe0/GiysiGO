using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.IntegrationTests
{
    [ApiController]
    [Route("test/authentication")]
    public sealed class TestAuthenticationController(ICurrentUser currentUser) : ControllerBase
    {
        [HttpGet]
        [Authorize]
        public IActionResult Get() => Ok(new { UserId = currentUser.UserId });
    }
}

using Microsoft.AspNetCore.Mvc;
using GiysiGo.API.Controllers;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.API.IntegrationTests
{
    [ApiController]
    [Route("test/authentication")]
    public sealed class TestAuthenticationController(ICurrentUser currentUser) : AuthenticatedApiControllerBase
    {
        [HttpGet]
        public IActionResult Get() => TryGetUserId(out var userId)
            ? Ok(new { UserId = userId, CurrentUserId = currentUser.UserId }) : Unauthorized();
    }
}

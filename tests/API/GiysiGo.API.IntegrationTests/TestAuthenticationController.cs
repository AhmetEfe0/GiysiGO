using Microsoft.AspNetCore.Mvc;
using GiysiGo.API.Controllers;

namespace GiysiGo.API.IntegrationTests
{
    [ApiController]
    [Route("test/authentication")]
    public sealed class TestAuthenticationController : AuthenticatedApiControllerBase
    {
        [HttpGet]
        public IActionResult Get() => TryGetUserId(out var userId)
            ? Ok(new { UserId = userId }) : Unauthorized();
    }
}

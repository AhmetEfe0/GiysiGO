using GiysiGo.API.Errors;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.Controllers.Identity
{
    [Route("auth")]
    public sealed class AuthController(IAuthService auth) : ApiControllerBase
    {
        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
        {
            try
            {
                var userId = await auth.RegisterAsync(request.Email, request.Password, cancellationToken);
                return StatusCode(StatusCodes.Status201Created, new { UserId = userId });
            }
            catch (ArgumentException exception) when (exception.ParamName is "email" or "password")
            {
                var problem = new ValidationProblemDetails(new Dictionary<string, string[]> { [exception.ParamName] = [exception.Message] })
                {
                    Status = StatusCodes.Status400BadRequest
                };
                ApiProblem.Complete(HttpContext, problem);
                return new BadRequestObjectResult(problem);
            }
            catch (SqlException exception) when (exception.Number is 2601 or 2627)
            {
                return Failure(409, "email_conflict", "Email address is already registered.");
            }
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
        {
            var result = await auth.LoginAsync(request.Email, request.Password, cancellationToken);
            Response.Headers.CacheControl = "no-store";
            Response.Headers.Pragma = "no-cache";
            return result is null ? Failure(401, "invalid_credentials", "Invalid credentials.") : Ok(result);
        }

        [HttpPost("refresh")]
        [AllowAnonymous]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request, CancellationToken cancellationToken)
        {
            var result = await auth.RefreshAsync(request.RefreshToken, cancellationToken);
            Response.Headers.CacheControl = "no-store";
            Response.Headers.Pragma = "no-cache";
            return result is null ? Failure(401, "invalid_refresh_token", "Invalid refresh token.") : Ok(result);
        }

        [HttpPost("logout")]
        [AllowAnonymous]
        public async Task<IActionResult> Logout([FromBody] RefreshRequest request, CancellationToken cancellationToken)
        {
            await auth.LogoutAsync(request.RefreshToken, cancellationToken);
            return NoContent();
        }

        private ObjectResult Failure(int status, string code, string detail)
        {
            var problem = ApiProblem.Create(HttpContext, status, detail: detail);
            problem.Extensions["code"] = code;
            var response = new ObjectResult(problem) { StatusCode = status };
            response.ContentTypes.Add("application/problem+json");
            return response;
        }
    }
}

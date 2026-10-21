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
            catch (ArgumentException exception)
            {
                var field = exception.ParamName is "email" or "password" ? exception.ParamName : string.Empty;
                var problem = new ValidationProblemDetails(new Dictionary<string, string[]> { [field] = [exception.Message] })
                {
                    Type = "https://httpstatuses.io/400",
                    Title = "Bad Request",
                    Status = StatusCodes.Status400BadRequest,
                    Detail = "Request validation failed.",
                    Instance = HttpContext.Request.Path
                };
                problem.Extensions["code"] = "validation_error";
                problem.Extensions["traceId"] = HttpContext.TraceIdentifier;
                var response = new ObjectResult(problem) { StatusCode = StatusCodes.Status400BadRequest };
                response.ContentTypes.Add("application/problem+json");
                return response;
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
            var problem = new ProblemDetails
            {
                Type = $"https://httpstatuses.io/{status}",
                Title = status switch { 400 => "Bad Request", 401 => "Unauthorized", 409 => "Conflict", _ => "Error" },
                Status = status,
                Detail = detail,
                Instance = HttpContext.Request.Path
            };
            problem.Extensions["code"] = code;
            problem.Extensions["traceId"] = HttpContext.TraceIdentifier;
            var response = new ObjectResult(problem) { StatusCode = status };
            response.ContentTypes.Add("application/problem+json");
            return response;
        }
    }
}

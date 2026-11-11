using GiysiGo.API.Errors;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Policy;

namespace GiysiGo.API.Authorization
{
    public sealed class ProblemDetailsAuthorizationResultHandler : IAuthorizationMiddlewareResultHandler
    {
        private readonly AuthorizationMiddlewareResultHandler defaultHandler = new();

        public async Task HandleAsync(RequestDelegate next, HttpContext context,
            AuthorizationPolicy policy, PolicyAuthorizationResult authorizeResult)
        {
            await defaultHandler.HandleAsync(next, context, policy, authorizeResult);

            if (context.Response.HasStarted)
            {
                return;
            }

            var statusCode = context.Response.StatusCode;
            if ((authorizeResult.Challenged && statusCode == StatusCodes.Status401Unauthorized)
                || (authorizeResult.Forbidden && statusCode == StatusCodes.Status403Forbidden))
            {
                await Results.Problem(ApiProblem.Create(context, statusCode)).ExecuteAsync(context);
            }
        }
    }
}

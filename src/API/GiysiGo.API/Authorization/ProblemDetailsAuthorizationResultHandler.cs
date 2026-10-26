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

            if (authorizeResult.Challenged)
            {
                if (context.Response.StatusCode != StatusCodes.Status401Unauthorized)
                {
                    return;
                }

                await Results.Problem(statusCode: StatusCodes.Status401Unauthorized,
                    title: "Unauthorized", type: "https://httpstatuses.io/401",
                    detail: "Authentication is required.", instance: context.Request.Path,
                    extensions: new Dictionary<string, object?>
                    {
                        ["code"] = "unauthorized", ["traceId"] = context.TraceIdentifier
                    }).ExecuteAsync(context);
                return;
            }

            if (authorizeResult.Forbidden)
            {
                if (context.Response.StatusCode != StatusCodes.Status403Forbidden)
                {
                    return;
                }

                await Results.Problem(statusCode: StatusCodes.Status403Forbidden,
                    title: "Forbidden", type: "https://httpstatuses.io/403",
                    detail: "You do not have permission for this resource.", instance: context.Request.Path,
                    extensions: new Dictionary<string, object?>
                    {
                        ["code"] = "forbidden", ["traceId"] = context.TraceIdentifier
                    }).ExecuteAsync(context);
            }
        }
    }
}

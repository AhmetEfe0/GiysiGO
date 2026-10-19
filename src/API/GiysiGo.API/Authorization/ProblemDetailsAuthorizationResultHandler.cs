using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Policy;

namespace GiysiGo.API.Authorization
{
    public sealed class ProblemDetailsAuthorizationResultHandler : IAuthorizationMiddlewareResultHandler
    {
        public Task HandleAsync(RequestDelegate next, HttpContext context,
            AuthorizationPolicy policy, PolicyAuthorizationResult authorizeResult)
        {
            if (authorizeResult.Challenged)
            {
                return Results.Problem(statusCode: StatusCodes.Status401Unauthorized,
                    title: "Unauthorized", type: "https://httpstatuses.io/401",
                    detail: "Authentication is required.", instance: context.Request.Path,
                    extensions: new Dictionary<string, object?>
                    {
                        ["code"] = "unauthorized", ["traceId"] = context.TraceIdentifier
                    }).ExecuteAsync(context);
            }

            if (authorizeResult.Forbidden)
            {
                return Results.Problem(statusCode: StatusCodes.Status403Forbidden,
                    title: "Forbidden", type: "https://httpstatuses.io/403",
                    detail: "You do not have permission for this resource.", instance: context.Request.Path,
                    extensions: new Dictionary<string, object?>
                    {
                        ["code"] = "forbidden", ["traceId"] = context.TraceIdentifier
                    }).ExecuteAsync(context);
            }

            return next(context);
        }
    }
}

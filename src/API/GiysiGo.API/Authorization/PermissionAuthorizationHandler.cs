using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authorization;

namespace GiysiGo.API.Authorization
{
    public sealed class PermissionAuthorizationHandler(ICurrentUser currentUser)
        : AuthorizationHandler<PermissionRequirement>
    {
        protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context,
            PermissionRequirement requirement)
        {
            if (context.Resource is not HttpContext httpContext
                || !currentUser.IsAuthenticated || currentUser.UserId is not { } userId)
            {
                return;
            }

            if (!ReadRouteId(httpContext, "corporateId", out var corporateId)
                || !ReadRouteId(httpContext, "storeId", out var storeId))
            {
                return;
            }

            var permissionChecker = httpContext.RequestServices.GetRequiredService<IPermissionChecker>();
            if (await permissionChecker.HasPermissionAsync(userId, requirement.Code,
                corporateId, storeId, httpContext.RequestAborted))
            {
                context.Succeed(requirement);
            }
        }

        private static bool ReadRouteId(HttpContext context, string key, out Guid? value)
        {
            value = null;
            if (!context.Request.RouteValues.TryGetValue(key, out var raw))
            {
                return true;
            }

            if (!Guid.TryParse(raw?.ToString(), out var parsed) || parsed == Guid.Empty)
            {
                return false;
            }

            value = parsed;
            return true;
        }
    }
}

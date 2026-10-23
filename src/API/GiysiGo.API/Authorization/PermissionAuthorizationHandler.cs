using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authorization;

namespace GiysiGo.API.Authorization
{
    public sealed class PermissionAuthorizationHandler(ICurrentUser currentUser, IHttpContextAccessor accessor)
        : AuthorizationHandler<PermissionRequirement>
    {
        protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
        {
            var http = accessor.HttpContext;
            if (!currentUser.IsAuthenticated || currentUser.UserId is not Guid userId || http is null) return;
            var permissions = http.RequestServices.GetRequiredService<IPermissionChecker>();
            if (await permissions.HasPermissionAsync(userId, requirement.PermissionCode, cancellationToken: http.RequestAborted))
                context.Succeed(requirement);
        }
    }
}

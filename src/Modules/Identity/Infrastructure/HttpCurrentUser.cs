using System.Security.Claims;
using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Http;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class HttpCurrentUser(IHttpContextAccessor accessor) : ICurrentUser
    {
        public Guid? UserId => accessor.HttpContext?.User.Identity?.IsAuthenticated == true
            && Guid.TryParse(accessor.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier), out var id)
            && id != Guid.Empty ? id : null;

        public bool IsAuthenticated => UserId.HasValue;
    }
}

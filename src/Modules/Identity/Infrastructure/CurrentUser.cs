using System.Security.Claims;
using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Http;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class CurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
    {
        public Guid? UserId
        {
            get
            {
                var principal = httpContextAccessor.HttpContext?.User;
                if (principal?.Identity?.IsAuthenticated != true)
                {
                    return null;
                }

                var value = principal.FindFirstValue(ClaimTypes.NameIdentifier)
                    ?? principal.FindFirstValue("sub");
                return Guid.TryParse(value, out var id) && id != Guid.Empty ? id : null;
            }
        }

        public bool IsAuthenticated => UserId.HasValue;
    }
}

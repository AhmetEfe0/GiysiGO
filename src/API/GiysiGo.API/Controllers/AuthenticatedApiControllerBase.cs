using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace GiysiGo.API.Controllers
{
    [Authorize]
    public abstract class AuthenticatedApiControllerBase : ApiControllerBase
    {
        protected bool TryGetUserId(out Guid userId)
            => Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
    }
}

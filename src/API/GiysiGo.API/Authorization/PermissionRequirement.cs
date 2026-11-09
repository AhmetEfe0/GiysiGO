using Microsoft.AspNetCore.Authorization;

namespace GiysiGo.API.Authorization
{
    public sealed record PermissionRequirement(string PermissionCode) : IAuthorizationRequirement;
}

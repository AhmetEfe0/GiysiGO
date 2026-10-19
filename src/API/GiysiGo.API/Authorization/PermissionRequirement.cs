using Microsoft.AspNetCore.Authorization;

namespace GiysiGo.API.Authorization
{
    public sealed class PermissionRequirement(string code) : IAuthorizationRequirement
    {
        public string Code { get; } = code;
    }
}

using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;

namespace GiysiGo.Modules.Identity.Tests
{
    public sealed class TestAccessTokenIssuer : IAccessTokenIssuer
    {
        public (string Token, DateTime ExpiresAtUtc) Issue(Guid userId)
            => (userId.ToString(), DateTime.UtcNow.AddMinutes(15));
    }
}

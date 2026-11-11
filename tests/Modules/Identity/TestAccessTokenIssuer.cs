using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;

namespace GiysiGo.Modules.Identity.Tests
{
    public sealed class TestAccessTokenIssuer : IAccessTokenIssuer
    {
        public bool FailIssuance { get; set; }

        public (string Token, DateTime ExpiresAtUtc) Issue(Guid userId)
        {
            if (FailIssuance)
                throw new InvalidOperationException("Test token issuance failed.");

            return (userId.ToString(), DateTime.UtcNow.AddMinutes(15));
        }
    }
}

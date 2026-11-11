namespace GiysiGo.Modules.Identity.Application.Interfaces.Authentication
{
    public interface IAccessTokenIssuer
    {
        (string Token, DateTime ExpiresAtUtc) Issue(Guid userId);
    }
}

namespace GiysiGo.Modules.Identity.Application.Interfaces.Authentication
{
    public sealed record AuthTokenResult(string AccessToken, string RefreshToken, DateTime ExpiresAtUtc);
}

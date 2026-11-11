using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using Microsoft.IdentityModel.Tokens;

namespace GiysiGo.API.Authentication
{
    public sealed class JwtAccessTokenIssuer(IConfiguration configuration) : IAccessTokenIssuer
    {
        public (string Token, DateTime ExpiresAtUtc) Issue(Guid userId)
        {
            var jwt = configuration.GetSection("Jwt");
            var issuer = jwt["Issuer"];
            var audience = jwt["Audience"];
            var secret = jwt["SigningKey"];
            if (string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(audience)
                || string.IsNullOrWhiteSpace(secret) || Encoding.UTF8.GetByteCount(secret) < 32
                || !int.TryParse(jwt["AccessTokenMinutes"], out var minutes) || minutes is < 1 or > 60)
                throw new InvalidOperationException("Jwt issuer, audience, signing key and 1-60 minute lifetime are required.");

            var now = DateTime.UtcNow;
            var expires = now.AddMinutes(minutes);
            var token = new JwtSecurityToken(issuer, audience,
                [new Claim(JwtRegisteredClaimNames.Sub, userId.ToString())],
                notBefore: now, expires: expires,
                signingCredentials: new SigningCredentials(
                    new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)), SecurityAlgorithms.HmacSha256));
            return (new JwtSecurityTokenHandler().WriteToken(token), expires);
        }
    }
}

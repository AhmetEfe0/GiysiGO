using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class CatalogSecurityApplication : WebApplicationFactory<Program>
    {
        private readonly string signingKey = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

        protected override void ConfigureWebHost(IWebHostBuilder builder)
            => builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
                new Dictionary<string, string?>
                {
                    ["ConnectionStrings:GiysiGo"] = Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION"),
                    ["Jwt:Issuer"] = "GiysiGo.Test",
                    ["Jwt:Audience"] = "GiysiGo.Test.Client",
                    ["Jwt:SigningKey"] = signingKey
                }));

        public string Token(string subject, bool expired = false, bool wrongSignature = false,
            string issuer = "GiysiGo.Test", string audience = "GiysiGo.Test.Client", IEnumerable<Claim>? extraClaims = null)
        {
            var claims = new[] { new Claim("sub", subject), new Claim("jti", Guid.NewGuid().ToString()) }
                .Concat(extraClaims ?? []);
            var key = wrongSignature ? Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)) : signingKey;
            var token = new JwtSecurityToken(issuer, audience, claims,
                notBefore: DateTime.UtcNow.AddHours(-2), expires: DateTime.UtcNow.AddHours(expired ? -1 : 1),
                signingCredentials: new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)), SecurityAlgorithms.HmacSha256));
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}

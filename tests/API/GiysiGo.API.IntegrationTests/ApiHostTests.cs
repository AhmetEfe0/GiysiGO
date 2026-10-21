using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using System.Security.Cryptography;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class ApiHostTests
    {
        [Fact]
        public async Task Health_endpoint_is_available()
        {
            var key = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48));
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
                    new Dictionary<string, string?> { ["Jwt:SigningKey"] = key,
                        ["Jwt:Issuer"] = "GiysiGo.Tests", ["Jwt:Audience"] = "GiysiGo.Tests",
                        ["Jwt:AccessTokenMinutes"] = "15" })));
            using var client = application.CreateClient();

            using var response = await client.GetAsync("/health");

            Assert.True(response.IsSuccessStatusCode);
        }
    }
}

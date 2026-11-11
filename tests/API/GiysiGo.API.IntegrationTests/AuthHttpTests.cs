using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Mvc.ApplicationParts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class AuthHttpTests
    {
        [SqlServerFact]
        public async Task Register_login_protected_refresh_replay_and_logout()
        {
            var connection = Environment.GetEnvironmentVariable("GIYSIGO_IDENTITY_TEST_CONNECTION")!;
            Assert.StartsWith("GiysiGo_IdentityTest_", new SqlConnectionStringBuilder(connection).InitialCatalog, StringComparison.Ordinal);
            var key = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48));
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            {
                builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
                    new Dictionary<string, string?>
                    {
                        ["ConnectionStrings:GiysiGo"] = connection,
                        ["Jwt:SigningKey"] = key,
                        ["Jwt:Issuer"] = "GiysiGo.Tests",
                        ["Jwt:Audience"] = "GiysiGo.Tests",
                        ["Jwt:AccessTokenMinutes"] = "15"
                    }));
                builder.ConfigureTestServices(services => services.AddControllers()
                    .AddApplicationPart(typeof(TestAuthenticationController).Assembly));
            });
            using var client = application.CreateClient();
            var email = $"api-{Guid.NewGuid():N}@example.test";
            using var invalidRegister = await client.PostAsJsonAsync("/auth/register", new { email, password = "short" });
            Assert.Equal(HttpStatusCode.BadRequest, invalidRegister.StatusCode);
            var invalidProblem = await invalidRegister.Content.ReadFromJsonAsync<ProblemDetails>();
            Assert.Equal("validation_failed", invalidProblem?.Extensions["code"]?.ToString());
            var validationErrors = Assert.IsType<JsonElement>(invalidProblem?.Extensions["errors"]);
            Assert.True(validationErrors.TryGetProperty("password", out _));
            using var unexpectedField = await client.PostAsJsonAsync("/auth/register", new { email, password = "a-very-long-password", displayName = "Test" });
            Assert.Equal(HttpStatusCode.BadRequest, unexpectedField.StatusCode);
            using var register = await client.PostAsJsonAsync("/auth/register", new { email, password = "a-very-long-password" });
            Assert.Equal(HttpStatusCode.Created, register.StatusCode);
            using var registration = JsonDocument.Parse(await register.Content.ReadAsStringAsync());
            var userId = registration.RootElement.GetProperty("userId").GetGuid();
            using var duplicate = await client.PostAsJsonAsync("/auth/register", new { email = email.ToUpperInvariant(), password = "a-very-long-password" });
            Assert.Equal(HttpStatusCode.Conflict, duplicate.StatusCode);
            using var wrong = await client.PostAsJsonAsync("/auth/login", new { email, password = "wrong-password" });
            Assert.Equal(HttpStatusCode.Unauthorized, wrong.StatusCode);

            using var loginResponse = await client.PostAsJsonAsync("/auth/login", new { email, password = "a-very-long-password" });
            Assert.Equal(HttpStatusCode.OK, loginResponse.StatusCode);
            var login = await loginResponse.Content.ReadFromJsonAsync<AuthTokenResult>();
            Assert.NotNull(login);
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", login.AccessToken);
            using var protectedResponse = await client.GetAsync("/test/authentication");
            Assert.Equal(HttpStatusCode.OK, protectedResponse.StatusCode);
            using (var protectedResult = JsonDocument.Parse(await protectedResponse.Content.ReadAsStringAsync()))
            {
                Assert.Equal(userId, protectedResult.RootElement.GetProperty("userId").GetGuid());
                Assert.Equal(userId, protectedResult.RootElement.GetProperty("currentUserId").GetGuid());
            }

            using var refreshResponse = await client.PostAsJsonAsync("/auth/refresh", new { refreshToken = login.RefreshToken });
            Assert.Equal(HttpStatusCode.OK, refreshResponse.StatusCode);
            var refreshed = await refreshResponse.Content.ReadFromJsonAsync<AuthTokenResult>();
            Assert.NotNull(refreshed);
            using var replay = await client.PostAsJsonAsync("/auth/refresh", new { refreshToken = login.RefreshToken });
            Assert.Equal(HttpStatusCode.Unauthorized, replay.StatusCode);
            using var logout = await client.PostAsJsonAsync("/auth/logout", new { refreshToken = refreshed.RefreshToken });
            Assert.Equal(HttpStatusCode.NoContent, logout.StatusCode);
            using var revoked = await client.PostAsJsonAsync("/auth/refresh", new { refreshToken = refreshed.RefreshToken });
            Assert.Equal(HttpStatusCode.Unauthorized, revoked.StatusCode);

            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", login.AccessToken + "tampered");
            using var invalid = await client.GetAsync("/test/authentication");
            Assert.Equal(HttpStatusCode.Unauthorized, invalid.StatusCode);

            var expiredJwt = new JwtSecurityToken("GiysiGo.Tests", "GiysiGo.Tests",
                [new Claim(JwtRegisteredClaimNames.Sub, userId.ToString())],
                notBefore: DateTime.UtcNow.AddHours(-1), expires: DateTime.UtcNow.AddMinutes(-1),
                signingCredentials: new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)), SecurityAlgorithms.HmacSha256));
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", new JwtSecurityTokenHandler().WriteToken(expiredJwt));
            using var expired = await client.GetAsync("/test/authentication");
            Assert.Equal(HttpStatusCode.Unauthorized, expired.StatusCode);

            using (var scope = application.Services.CreateScope())
            {
                var transactions = scope.ServiceProvider.GetRequiredService<ITransactionRunner>();
                var users = scope.ServiceProvider.GetRequiredService<IUserRepository>();
                await transactions.ExecuteAsync(async (db, transaction, token) =>
                {
                    await users.SetActiveAsync(userId, false, db, transaction, token);
                    return true;
                });
            }
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", login.AccessToken);
            using var inactive = await client.GetAsync("/test/authentication");
            Assert.Equal(HttpStatusCode.Unauthorized, inactive.StatusCode);
        }
    }
}

using System.Net;
using System.Net.Http.Json;
using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApplicationParts;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class PermissionHttpTests
    {
        [Fact]
        public async Task Permission_policy_returns_problem_details_and_passes_route_scope()
        {
            var checker = new TestPermissionChecker();
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.ConfigureTestServices(services =>
                {
                    services.AddControllers().AddApplicationPart(typeof(TestPermissionController).Assembly);
                    services.AddAuthentication(options =>
                    {
                        options.DefaultAuthenticateScheme = "Test";
                        options.DefaultChallengeScheme = "Test";
                    }).AddScheme<AuthenticationSchemeOptions, TestAuthenticationHandler>("Test", _ => { });
                    services.AddSingleton<IPermissionChecker>(checker);
                }));
            using var client = application.CreateClient();
            var userId = Guid.NewGuid();
            var corporateId = Guid.NewGuid();
            var storeId = Guid.NewGuid();
            var path = $"/test/permissions/corporates/{corporateId}/stores/{storeId}";

            using var anonymous = await client.GetAsync(path);
            Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
            Assert.Equal("application/problem+json", anonymous.Content.Headers.ContentType?.MediaType);
            var anonymousProblem = await anonymous.Content.ReadFromJsonAsync<ProblemDetails>();
            Assert.Equal(401, anonymousProblem?.Status);
            Assert.Equal(path, anonymousProblem?.Instance);
            Assert.Null(checker.SeenUserId);

            client.DefaultRequestHeaders.Add("X-Test-User", userId.ToString());
            using var forbidden = await client.GetAsync(path);
            Assert.Equal(HttpStatusCode.Forbidden, forbidden.StatusCode);
            Assert.Equal("application/problem+json", forbidden.Content.Headers.ContentType?.MediaType);
            var forbiddenProblem = await forbidden.Content.ReadFromJsonAsync<ProblemDetails>();
            Assert.Equal(403, forbiddenProblem?.Status);
            Assert.Equal(path, forbiddenProblem?.Instance);
            Assert.Equal(userId, checker.SeenUserId);
            Assert.Equal(PermissionCodes.StoreView, checker.SeenPermission);
            Assert.Equal(corporateId, checker.SeenCorporateId);
            Assert.Equal(storeId, checker.SeenStoreId);

            checker.Grant(userId, PermissionCodes.StoreView, corporateId, storeId);
            using var allowed = await client.GetAsync(path);
            Assert.Equal(HttpStatusCode.OK, allowed.StatusCode);

            using var otherStore = await client.GetAsync(
                $"/test/permissions/corporates/{corporateId}/stores/{Guid.NewGuid()}");
            Assert.Equal(HttpStatusCode.Forbidden, otherStore.StatusCode);
        }
    }
}

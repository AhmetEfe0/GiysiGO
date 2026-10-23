using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text.Json;
using GiysiGo.API.Controllers.Catalog;
using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class CatalogAuthorizationTests
    {
        [CatalogDatabaseFact]
        public async Task Customer_staff_and_owner_cannot_write_platform_catalog_even_with_forged_role_claims()
        {
            await using var fixture = await CatalogSecurityFixture.CreateAsync();
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            foreach (var userId in new[] { fixture.CustomerId, fixture.StaffId, fixture.OwnerId })
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", application.Token(userId.ToString(),
                    extraClaims: [new Claim("role", "PlatformAdmin"), new Claim("permission", "catalog.manage"), new Claim(ClaimTypes.NameIdentifier, fixture.AdminId.ToString())]));
                foreach (var route in new[] { "categories", "product-types", "services", "product-type-services" })
                {
                    using var created = await client.PostAsJsonAsync($"/catalog/{route}?userId={fixture.AdminId}", new { code = fixture.CodePrefix, name = "Yetkisiz kayıt", userId = fixture.AdminId });
                    await AssertProblemAsync(created, HttpStatusCode.Forbidden, "permission_denied");
                    using var updated = await client.PutAsJsonAsync($"/catalog/{route}/{Guid.NewGuid()}", new { name = "Yetkisiz güncelleme" });
                    await AssertProblemAsync(updated, HttpStatusCode.Forbidden, "permission_denied");
                    using var deleted = await client.DeleteAsync($"/catalog/{route}/{Guid.NewGuid()}");
                    await AssertProblemAsync(deleted, HttpStatusCode.Forbidden, "permission_denied");
                }
            }
        }

        [CatalogDatabaseFact]
        public async Task Invalid_expired_or_mismatched_tokens_and_subjects_are_rejected()
        {
            await using var fixture = await CatalogSecurityFixture.CreateAsync();
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            var subject = fixture.AdminId.ToString();
            var invalidTokens = new[]
            {
                application.Token(subject, expired: true), application.Token(subject, wrongSignature: true),
                application.Token(subject, issuer: "YanlisIssuer"), application.Token(subject, audience: "YanlisAudience"),
                application.Token("bozuk-guid"), application.Token(Guid.Empty.ToString()),
                application.Token(subject, extraClaims: [new Claim("sub", fixture.CustomerId.ToString())]),
                application.Token(Guid.NewGuid().ToString()), "bozuk-token"
            };
            foreach (var token in invalidTokens)
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                using var response = await client.PostAsJsonAsync("/catalog/categories", new { code = fixture.CodePrefix, name = "Token testi" });
                await AssertProblemAsync(response, HttpStatusCode.Unauthorized, "authentication_required");
            }
        }

        [CatalogDatabaseFact]
        public async Task Database_revocations_take_effect_before_access_token_expiry()
        {
            foreach (var operation in new[] { "REVOKE_ADMIN", "DISABLE_ADMIN", "DELETE_ADMIN" })
            {
                await using var fixture = await CatalogSecurityFixture.CreateAsync();
                await using var application = new CatalogSecurityApplication();
                using var client = application.CreateClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", application.Token(fixture.AdminId.ToString()));
                using var allowed = await client.PostAsJsonAsync("/catalog/categories", new { code = fixture.CodePrefix, name = "İptal testi" });
                Assert.Equal(HttpStatusCode.Created, allowed.StatusCode);
                await fixture.ExecuteAsync(operation);
                using var denied = await client.PostAsJsonAsync("/catalog/categories", new { code = fixture.CodePrefix + "-sonra", name = "İptal sonrası" });
                await AssertProblemAsync(denied,
                    operation == "REVOKE_ADMIN" ? HttpStatusCode.Forbidden : HttpStatusCode.Unauthorized,
                    operation == "REVOKE_ADMIN" ? "permission_denied" : "authentication_required");
            }
        }

        [CatalogDatabaseFact]
        public async Task Permission_checker_enforces_real_store_and_corporate_scope_and_revocations()
        {
            await using var fixture = await CatalogSecurityFixture.CreateAsync();
            await using var application = new CatalogSecurityApplication();
            await using var scope = application.Services.CreateAsyncScope();
            var checker = scope.ServiceProvider.GetRequiredService<IPermissionChecker>();
            Assert.True(await checker.HasPermissionAsync(fixture.AdminId, PermissionCodes.CatalogManage));
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.CatalogManage));
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare));
            Assert.True(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare, storeId: fixture.StoreA));
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuoteApprove, storeId: fixture.StoreA));
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare, storeId: fixture.StoreB));
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare, fixture.CorporateB, fixture.StoreA));
            Assert.True(await checker.HasPermissionAsync(fixture.OwnerId, PermissionCodes.OrderView, corporateId: fixture.CorporateA));
            Assert.True(await checker.HasPermissionAsync(fixture.OwnerId, PermissionCodes.OrderView, storeId: fixture.StoreA));
            Assert.False(await checker.HasPermissionAsync(fixture.OwnerId, PermissionCodes.OrderView, corporateId: fixture.CorporateB));
            Assert.False(await checker.HasPermissionAsync(fixture.OwnerId, PermissionCodes.OrderView, storeId: fixture.StoreB));
            Assert.False(await checker.HasPermissionAsync(fixture.AdminId, "bilinmeyen.permission"));
            Assert.False(await checker.HasPermissionAsync(Guid.NewGuid(), PermissionCodes.CatalogManage));
            Assert.False(await checker.HasPermissionAsync(fixture.AdminId, PermissionCodes.OrderView, storeId: Guid.NewGuid()));

            await fixture.ExecuteAsync("DISABLE_STAFF_ROLE");
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare, storeId: fixture.StoreA));
            await fixture.ExecuteAsync("ENABLE_STAFF_ROLE");
            Assert.True(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare, storeId: fixture.StoreA));
            await fixture.ExecuteAsync("REVOKE_STAFF");
            Assert.False(await checker.HasPermissionAsync(fixture.StaffId, PermissionCodes.QuotePrepare, storeId: fixture.StoreA));
            await fixture.ExecuteAsync("DISABLE_OWNER_MEMBERSHIP");
            Assert.False(await checker.HasPermissionAsync(fixture.OwnerId, PermissionCodes.OrderView, storeId: fixture.StoreA));
            await fixture.ExecuteAsync("DISABLE_STORE");
            Assert.False(await checker.HasPermissionAsync(fixture.AdminId, PermissionCodes.OrderView, storeId: fixture.StoreA));
            await fixture.ExecuteAsync("DISABLE_CORPORATE");
            Assert.False(await checker.HasPermissionAsync(fixture.AdminId, PermissionCodes.OrderView, corporateId: fixture.CorporateA));
        }

        private static async Task AssertProblemAsync(HttpResponseMessage response, HttpStatusCode expected, string code)
        {
            Assert.Equal(expected, response.StatusCode);
            Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
            using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            Assert.Equal(code, json.RootElement.GetProperty("code").GetString());
            Assert.False(string.IsNullOrWhiteSpace(json.RootElement.GetProperty("traceId").GetString()));
        }
    }
}

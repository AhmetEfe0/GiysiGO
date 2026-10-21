using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text.Json;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class MeHttpTests
    {
        [SqlServerFact]
        public async Task Addresses_and_profile_require_owner_and_reject_invalid_inputs()
        {
            var connection = Environment.GetEnvironmentVariable("GIYSIGO_IDENTITY_TEST_CONNECTION")!;
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
                    new Dictionary<string, string?>
                    {
                        ["ConnectionStrings:GiysiGo"] = connection,
                        ["Jwt:SigningKey"] = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48)),
                        ["Jwt:Issuer"] = "GiysiGo.Tests", ["Jwt:Audience"] = "GiysiGo.Tests"
                    })));
            using var owner = application.CreateClient();
            using var other = application.CreateClient();
            using var anonymous = await owner.GetAsync("/me/addresses");
            Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
            using (var problem = JsonDocument.Parse(await anonymous.Content.ReadAsStringAsync()))
                Assert.Equal("unauthorized", problem.RootElement.GetProperty("code").GetString());
            var ownerEmail = $"owner-{Guid.NewGuid():N}@example.test";
            var otherEmail = $"other-{Guid.NewGuid():N}@example.test";
            Assert.Equal(HttpStatusCode.Created, (await owner.PostAsJsonAsync("/auth/register", new { email = ownerEmail, password = "a-very-long-password" })).StatusCode);
            Assert.Equal(HttpStatusCode.Created, (await other.PostAsJsonAsync("/auth/register", new { email = otherEmail, password = "a-very-long-password" })).StatusCode);
            var ownerToken = await (await owner.PostAsJsonAsync("/auth/login", new { email = ownerEmail, password = "a-very-long-password" })).Content.ReadFromJsonAsync<AuthTokenResult>();
            var otherToken = await (await other.PostAsJsonAsync("/auth/login", new { email = otherEmail, password = "a-very-long-password" })).Content.ReadFromJsonAsync<AuthTokenResult>();
            owner.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", ownerToken!.AccessToken);
            other.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", otherToken!.AccessToken);

            var address = new { label = "Ev", addressText = "İstanbul", latitude = 41.123456m,
                longitude = 29.654321m, contactName = "Ada", contactPhone = "5550000000" };
            using var invalid = await owner.PostAsJsonAsync("/me/addresses", new { address.label, address.addressText,
                latitude = 91, address.longitude, address.contactName, address.contactPhone });
            Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
            using (var problem = JsonDocument.Parse(await invalid.Content.ReadAsStringAsync()))
                Assert.Equal("validation_error", problem.RootElement.GetProperty("code").GetString());
            using var invalidPhone = await owner.PostAsJsonAsync("/me/addresses", new { address.label,
                address.addressText, address.latitude, address.longitude, address.contactName,
                contactPhone = "abc" });
            Assert.Equal(HttpStatusCode.BadRequest, invalidPhone.StatusCode);
            using (var problem = JsonDocument.Parse(await invalidPhone.Content.ReadAsStringAsync()))
                Assert.Equal("validation_error", problem.RootElement.GetProperty("code").GetString());
            using var created = await owner.PostAsJsonAsync("/me/addresses", address);
            Assert.Equal(HttpStatusCode.Created, created.StatusCode);
            using var createdBody = JsonDocument.Parse(await created.Content.ReadAsStringAsync());
            var addressId = createdBody.RootElement.GetProperty("id").GetGuid();
            Assert.NotEqual(Guid.Empty, addressId);
            using var otherRead = await other.GetAsync($"/me/addresses/{addressId}");
            Assert.Equal(HttpStatusCode.NotFound, otherRead.StatusCode);
            using (var problem = JsonDocument.Parse(await otherRead.Content.ReadAsStringAsync()))
                Assert.Equal("not_found", problem.RootElement.GetProperty("code").GetString());
            using var otherUpdate = await other.PutAsJsonAsync($"/me/addresses/{addressId}", address);
            Assert.Equal(HttpStatusCode.NotFound, otherUpdate.StatusCode);
            using var otherDelete = await other.DeleteAsync($"/me/addresses/{addressId}");
            Assert.Equal(HttpStatusCode.NotFound, otherDelete.StatusCode);
            using var otherList = await other.GetAsync("/me/addresses");
            Assert.Equal(HttpStatusCode.OK, otherList.StatusCode);
            using (var page = JsonDocument.Parse(await otherList.Content.ReadAsStringAsync()))
                Assert.Equal(0, page.RootElement.GetProperty("totalCount").GetInt32());
            using var ownerList = await owner.GetAsync("/me/addresses?page=1&pageSize=20");
            Assert.Equal(HttpStatusCode.OK, ownerList.StatusCode);
            using (var page = JsonDocument.Parse(await ownerList.Content.ReadAsStringAsync()))
            {
                Assert.Equal(1, page.RootElement.GetProperty("totalCount").GetInt32());
                Assert.Equal(addressId, page.RootElement.GetProperty("items")[0].GetProperty("id").GetGuid());
            }
            using var invalidPage = await owner.GetAsync("/me/addresses?pageSize=101");
            Assert.Equal(HttpStatusCode.BadRequest, invalidPage.StatusCode);
            using (var problem = JsonDocument.Parse(await invalidPage.Content.ReadAsStringAsync()))
                Assert.Equal("validation_error", problem.RootElement.GetProperty("code").GetString());
            using var beyondPage = await owner.GetAsync("/me/addresses?page=2&pageSize=1");
            Assert.Equal(HttpStatusCode.OK, beyondPage.StatusCode);
            using (var page = JsonDocument.Parse(await beyondPage.Content.ReadAsStringAsync()))
            {
                Assert.Equal(1, page.RootElement.GetProperty("totalCount").GetInt32());
                Assert.Empty(page.RootElement.GetProperty("items").EnumerateArray());
            }

            using var updatedAddress = await owner.PutAsJsonAsync($"/me/addresses/{addressId}", new
            {
                address.label, addressText = "Yeni adres", address.latitude, address.longitude,
                contactName = "Ali", address.contactPhone
            });
            Assert.Equal(HttpStatusCode.NoContent, updatedAddress.StatusCode);
            using var ownedAddress = await owner.GetAsync($"/me/addresses/{addressId}");
            Assert.Equal(HttpStatusCode.OK, ownedAddress.StatusCode);
            using (var body = JsonDocument.Parse(await ownedAddress.Content.ReadAsStringAsync()))
            {
                Assert.Equal("Yeni adres", body.RootElement.GetProperty("addressText").GetString());
                Assert.Equal("Ali", body.RootElement.GetProperty("contactName").GetString());
            }

            using var originalProfile = await owner.GetAsync("/me/profile");
            Assert.Equal(HttpStatusCode.OK, originalProfile.StatusCode);
            var profileBody = await originalProfile.Content.ReadAsStringAsync();
            Assert.DoesNotContain("passwordHash", profileBody, StringComparison.OrdinalIgnoreCase);
            Assert.DoesNotContain("isActive", profileBody, StringComparison.OrdinalIgnoreCase);
            using (var body = JsonDocument.Parse(profileBody))
                Assert.Equal(ownerEmail, body.RootElement.GetProperty("email").GetString());
            var newEmail = $"changed-{Guid.NewGuid():N}@example.test";
            using var unsafeProfile = await owner.PutAsJsonAsync("/me/profile", new { email = newEmail,
                passwordHash = "not-accepted", isActive = false });
            Assert.Equal(HttpStatusCode.BadRequest, unsafeProfile.StatusCode);
            using (var problem = JsonDocument.Parse(await unsafeProfile.Content.ReadAsStringAsync()))
                Assert.Equal("validation_error", problem.RootElement.GetProperty("code").GetString());
            using var changedProfile = await owner.PutAsJsonAsync("/me/profile", new { email = newEmail });
            Assert.Equal(HttpStatusCode.OK, changedProfile.StatusCode);
            using var changedBody = JsonDocument.Parse(await changedProfile.Content.ReadAsStringAsync());
            Assert.Equal(newEmail, changedBody.RootElement.GetProperty("email").GetString());
            using var duplicateEmail = await owner.PutAsJsonAsync("/me/profile", new { email = otherEmail });
            Assert.Equal(HttpStatusCode.Conflict, duplicateEmail.StatusCode);
            using (var problem = JsonDocument.Parse(await duplicateEmail.Content.ReadAsStringAsync()))
                Assert.Equal("email_conflict", problem.RootElement.GetProperty("code").GetString());
            Assert.Equal(HttpStatusCode.OK, (await owner.GetAsync($"/me/addresses/{addressId}")).StatusCode);
            using var deleted = await owner.DeleteAsync($"/me/addresses/{addressId}");
            Assert.Equal(HttpStatusCode.NoContent, deleted.StatusCode);
            using var missing = await owner.GetAsync($"/me/addresses/{addressId}");
            Assert.Equal(HttpStatusCode.NotFound, missing.StatusCode);
        }
    }
}

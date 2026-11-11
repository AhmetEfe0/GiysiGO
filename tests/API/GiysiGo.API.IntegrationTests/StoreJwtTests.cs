using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using GiysiGo.API.Controllers.Stores;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.BuildingBlocks.Application.Transactions;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreJwtTests
    {
        [StoreSqlFact]
        public async Task Gercek_JWT_ile_Identity_ve_dukkan_yonetimi_birlikte_calismali()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            var otherCorporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate);
            await using var app = new CatalogSecurityApplication();
            using var client = app.CreateClient();
            void Act(Guid user) => client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", app.Token(user.ToString()));
            var root = StoreTestDatabase.Path(corporate);
            using (var anonymous = await client.GetAsync(root))
            {
                Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
                Assert.Equal("Bearer", anonymous.Headers.WwwAuthenticate.ToString());
            }
            Act(owner);
            using var created = await client.PostAsJsonAsync(root, StoreTestDatabase.ValidRequest());
            Assert.Equal(HttpStatusCode.Created, created.StatusCode);
            var storeId = (await created.Content.ReadFromJsonAsync<StoreCreatedDto>())!.Id;
            var path = StoreTestDatabase.Path(corporate, storeId);
            using (var other = await client.GetAsync(StoreTestDatabase.Path(otherCorporate)))
                Assert.Equal(HttpStatusCode.Forbidden, other.StatusCode);
            var staff = await db.UserAsync("StoreStaff", storeId: storeId);
            Act(staff);
            using (var own = await client.GetAsync(path)) Assert.Equal(HttpStatusCode.OK, own.StatusCode);
            using (var list = await client.GetAsync(root)) Assert.Equal(HttpStatusCode.Forbidden, list.StatusCode);
            using (var update = await client.PutAsJsonAsync(path, StoreTestDatabase.ValidRequest()))
                Assert.Equal(HttpStatusCode.Forbidden, update.StatusCode);
            Act(owner);
            using (var deactivate = await client.PatchAsJsonAsync(path + "/active", new { isActive = false }))
                Assert.Equal(HttpStatusCode.NoContent, deactivate.StatusCode);
            Act(staff);
            using (var inactive = await client.GetAsync(path)) Assert.Equal(HttpStatusCode.Forbidden, inactive.StatusCode);
            Act(owner);
            using (var reactivate = await client.PatchAsJsonAsync(path + "/active", new { isActive = true }))
                Assert.Equal(HttpStatusCode.NoContent, reactivate.StatusCode);
            Act(staff);
            using (var restored = await client.GetAsync(path)) Assert.Equal(HttpStatusCode.OK, restored.StatusCode);
            await db.Get<ITransactionRunner>().ExecuteAsync(async (connection, transaction, token) =>
            {
                await db.Get<IUserRepository>().SetActiveAsync(staff, false, connection, transaction, token);
                return true;
            });
            using (var disabled = await client.GetAsync(path)) Assert.Equal(HttpStatusCode.Unauthorized, disabled.StatusCode);
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", app.Token(owner.ToString(), wrongSignature: true));
            using var forged = await client.GetAsync(root);
            Assert.Equal(HttpStatusCode.Unauthorized, forged.StatusCode);
        }
    }
}

using System.Net;
using System.Net.Http.Json;
using System.Net.Http.Headers;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Offerings;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreOfferingManagementHttpTests
    {
        [StoreSqlFact]
        public async Task Offering_commands_resolve_prices_and_enforce_store_scope()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); var owner = await db.UserAsync("CorporateOwner", corporate);
            db.ActAs(owner); var store = await db.CreateAsync(corporate); var other = await db.CreateAsync(corporate, "Other");
            var category = Guid.NewGuid(); var product = Guid.NewGuid(); var service = Guid.NewGuid();
            var pair = Guid.NewGuid(); var offering = Guid.NewGuid();
            object Parameters(string operation, string? hidden = null) => new
            {
                Operation = operation, Hidden = hidden, PriceOverride = (decimal?)null,
                CategoryId = category, ProductId = product, ServiceId = service,
                PairId = pair, OfferingId = offering, StoreId = store
            };
            var path = StoreTestDatabase.Path(corporate, store) + "/offerings";
            var itemPath = path + "/" + pair;
            var address = Guid.NewGuid(); var cart = Guid.NewGuid(); var order = Guid.NewGuid();
            var item = Guid.NewGuid(); var itemService = Guid.NewGuid(); var quote = Guid.NewGuid(); var line = Guid.NewGuid();
            object Snapshot(string operation) => new { Operation = operation, UserId = owner, StoreId = store, ProductId = product, PairId = pair,
                AddressId = address, CartId = cart, OrderId = order, ItemId = item, ItemServiceId = itemService, QuoteId = quote, LineId = line };
            try
            {
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Parameters("CREATE"));
                await db.ExecuteAsync("OfferingPriceSnapshots.sql", Snapshot("CREATE"));
                var reader = db.Get<IStoreCatalogReader>();
                using (var reset = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = (decimal?)null }))
                    Assert.Equal(HttpStatusCode.NoContent, reset.StatusCode);
                Assert.Equal(125.25m, (await reader.GetOfferingAsync(store, product, service))?.UnitPrice);
                using (var price = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = 155.50m }))
                    Assert.Equal(HttpStatusCode.NoContent, price.StatusCode);
                Assert.Equal(155.50m, (await reader.GetOfferingAsync(store, product, service))?.UnitPrice);
                using (var reset = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = (decimal?)null }))
                    Assert.Equal(HttpStatusCode.NoContent, reset.StatusCode);
                Assert.Equal(125.25m, (await reader.GetOfferingAsync(store, product, service))?.UnitPrice);
                for (var i = 0; i < 2; i++)
                {
                    using var save = await db.Client.PutAsJsonAsync(itemPath, new { isActive = true, priceOverride = 0m });
                    Assert.Equal(HttpStatusCode.NoContent, save.StatusCode);
                }
                var list = await db.Client.GetFromJsonAsync<ManagedOfferingPage>(path);
                Assert.NotNull(list); Assert.Equal(1, list.Page); Assert.Equal(20, list.PageSize); Assert.Equal(1, list.TotalCount);
                var row = Assert.Single(list.Items); Assert.Equal(offering, row.Id); Assert.Equal(0m, row.UnitPrice);
                Assert.Equal("TRY", row.Currency); Assert.Equal("PIECE", row.PriceUnit);
                using (var deactivate = await db.Client.PatchAsJsonAsync(itemPath + "/active", new { isActive = false }))
                    Assert.Equal(HttpStatusCode.NoContent, deactivate.StatusCode);
                Assert.Null(await reader.GetOfferingAsync(store, product, service));
                using (var activate = await db.Client.PatchAsJsonAsync(itemPath + "/active", new { isActive = true }))
                    Assert.Equal(HttpStatusCode.NoContent, activate.StatusCode);
                using (var invalid = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = 1.001m }))
                    Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
                using (var missing = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { }))
                    Assert.Equal(HttpStatusCode.BadRequest, missing.StatusCode);
                using (var invented = await db.Client.PutAsJsonAsync(path + "/" + Guid.NewGuid(), new { isActive = true, priceOverride = (decimal?)null }))
                    Assert.Equal(HttpStatusCode.NotFound, invented.StatusCode);
                foreach (var hidden in new[] { "category", "product", "service", "pair" })
                {
                    await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Parameters("CHANGE", hidden));
                    using var activate = await db.Client.PatchAsJsonAsync(itemPath + "/active", new { isActive = true });
                    Assert.Equal(HttpStatusCode.NotFound, activate.StatusCode);
                    Assert.Null(await reader.GetOfferingAsync(store, product, service));
                }
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Parameters("CHANGE"));
                var otherManager = await db.UserAsync("StoreManager", storeId: other);
                db.ActAs(otherManager);
                using (var forbidden = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = 9m }))
                    Assert.Equal(HttpStatusCode.Forbidden, forbidden.StatusCode);
                var ownManager = await db.UserAsync("StoreManager", storeId: store);
                db.ActAs(ownManager);
                using (var allowed = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = 9m }))
                    Assert.Equal(HttpStatusCode.NoContent, allowed.StatusCode);
                // The caller has the permission at another store; all four endpoints must reject this scope.
                db.ActAs(otherManager);
                using (var deniedList = await db.Client.GetAsync(path)) Assert.Equal(HttpStatusCode.Forbidden, deniedList.StatusCode);
                using (var deniedSave = await db.Client.PutAsJsonAsync(itemPath, new { isActive = true, priceOverride = 1m })) Assert.Equal(HttpStatusCode.Forbidden, deniedSave.StatusCode);
                using (var deniedActive = await db.Client.PatchAsJsonAsync(itemPath + "/active", new { isActive = false })) Assert.Equal(HttpStatusCode.Forbidden, deniedActive.StatusCode);
                Assert.Equal(9m, (await reader.GetOfferingAsync(store, product, service))?.UnitPrice);
                await using (var jwtApp = new CatalogSecurityApplication())
                {
                    using var jwtClient = jwtApp.CreateClient();
                    jwtClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwtApp.Token(ownManager.ToString()));
                    using (var jwtList = await jwtClient.GetAsync(path)) Assert.Equal(HttpStatusCode.OK, jwtList.StatusCode);
                    using (var jwtPrice = await jwtClient.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = 42.25m })) Assert.Equal(HttpStatusCode.NoContent, jwtPrice.StatusCode);
                    Assert.Equal(42.25m, (await reader.GetOfferingAsync(store, product, service))?.UnitPrice);
                    jwtClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwtApp.Token(otherManager.ToString()));
                    using (var wrongScope = await jwtClient.GetAsync(path)) Assert.Equal(HttpStatusCode.Forbidden, wrongScope.StatusCode);
                    jwtClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwtApp.Token(ownManager.ToString(), wrongSignature: true));
                    using (var badToken = await jwtClient.GetAsync(path)) Assert.Equal(HttpStatusCode.Unauthorized, badToken.StatusCode);
                }
                db.ActAs(owner);
                foreach (var invalidPrice in new[] { -0.01m, 10000000000m })
                {
                    using var rejected = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = invalidPrice });
                    Assert.Equal(HttpStatusCode.BadRequest, rejected.StatusCode);
                }
                using (var maximum = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = 9999999999.99m }))
                    Assert.Equal(HttpStatusCode.NoContent, maximum.StatusCode);
                Assert.Equal(9999999999.99m, (await reader.GetOfferingAsync(store, product, service))?.UnitPrice);
                using (var resetAgain = await db.Client.PatchAsJsonAsync(itemPath + "/price", new { priceOverride = (decimal?)null }))
                    Assert.Equal(HttpStatusCode.NoContent, resetAgain.StatusCode);
                using (var invalidPage = await db.Client.GetAsync(path + "?page=0")) Assert.Equal(HttpStatusCode.BadRequest, invalidPage.StatusCode);
                using (var invalidSize = await db.Client.GetAsync(path + "?pageSize=101")) Assert.Equal(HttpStatusCode.BadRequest, invalidSize.StatusCode);
                var overflowPage = await db.Client.GetFromJsonAsync<ManagedOfferingPage>(path + "?page=2147483647&pageSize=100");
                Assert.NotNull(overflowPage); Assert.Empty(overflowPage.Items); Assert.Equal(1, overflowPage.TotalCount);
                var absentItem = StoreTestDatabase.Path(corporate, other) + "/offerings/" + pair;
                using (var absentPrice = await db.Client.PatchAsJsonAsync(absentItem + "/price", new { priceOverride = 10m })) Assert.Equal(HttpStatusCode.NotFound, absentPrice.StatusCode);
                using (var absentActive = await db.Client.PatchAsJsonAsync(absentItem + "/active", new { isActive = true })) Assert.Equal(HttpStatusCode.NotFound, absentActive.StatusCode);
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Parameters("CHANGE", "pair"));
                using (var deactivateHidden = await db.Client.PatchAsJsonAsync(itemPath + "/active", new { isActive = false })) Assert.Equal(HttpStatusCode.NoContent, deactivateHidden.StatusCode);
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Parameters("CHANGE"));
                await db.ExecuteAsync("OfferingPriceSnapshots.sql", Snapshot("VERIFY"));
                db.ActAs(owner);
                foreach (var state in new[] { (Store: false, Corporate: true), (Store: true, Corporate: false) })
                {
                    await db.ExecuteAsync("OfferingLifecycle.sql", new { StoreId = store, CorporateId = corporate, StoreActive = state.Store, CorporateActive = state.Corporate });
                    Assert.Null(await reader.GetOfferingAsync(store, product, service));
                    using var blocked = await db.Client.PatchAsJsonAsync(itemPath + "/active", new { isActive = true });
                    Assert.Equal(HttpStatusCode.Forbidden, blocked.StatusCode);
                }
                await db.ExecuteAsync("OfferingLifecycle.sql", new { StoreId = store, CorporateId = corporate, StoreActive = true, CorporateActive = true });
                var newPath = StoreTestDatabase.Path(corporate, other) + "/offerings/" + pair;
                var concurrent = await Task.WhenAll(Enumerable.Range(0, 4).Select(_ => db.Client.PutAsJsonAsync(newPath, new { isActive = true, priceOverride = (decimal?)null })));
                foreach (var response in concurrent) { using (response) Assert.Equal(HttpStatusCode.NoContent, response.StatusCode); }
                Assert.Single((await db.Client.GetFromJsonAsync<ManagedOfferingPage>(StoreTestDatabase.Path(corporate, other) + "/offerings"))!.Items);
                await db.ExecuteAsync("OfferingManagementCleanup.sql", new { StoreId = other, PairId = pair });
            }
            finally
            {
                await db.ExecuteAsync("OfferingPriceSnapshots.sql", Snapshot("DELETE"));
                await db.ExecuteAsync("OfferingManagementCleanup.sql", new { StoreId = other, PairId = pair });
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Parameters("DELETE"));
            }
        }
    }
}

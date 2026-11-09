using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using GiysiGo.API.Controllers.Catalog;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class CatalogManagementTests
    {
        [CatalogDatabaseFact]
        public async Task Platform_admin_can_create_update_and_soft_delete_catalog_without_changing_stable_identity()
        {
            await using var fixture = await CatalogSecurityFixture.CreateAsync();
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", application.Token(fixture.AdminId.ToString()));
            var categoryRequest = new CatalogCategoryWriteRequest(fixture.CodePrefix + "-cat", "Test kategorisi");
            var category = await CreateAsync("categories", categoryRequest);
            var productRequest = new CatalogProductTypeWriteRequest(category, fixture.CodePrefix + "-product", "Test ürünü");
            var product = await CreateAsync("product-types", productRequest);
            var serviceRequest = new CatalogServiceWriteRequest(fixture.CodePrefix + "-service", "Test hizmeti");
            var service = await CreateAsync("services", serviceRequest);
            var otherService = await CreateAsync("services", new CatalogServiceWriteRequest(fixture.CodePrefix + "-other-service", "Başka hizmet"));
            var pairRequest = new CatalogProductTypeServiceWriteRequest(product, service, 123.45m, "PIECE", "BASE");
            var pair = await CreateAsync("product-type-services", pairRequest);

            await ExpectAsync(client.PutAsJsonAsync($"/catalog/categories/{category}", categoryRequest with { Name = "Yeni kategori", SortOrder = 4 }), HttpStatusCode.NoContent);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-types/{product}", productRequest with { Name = "Yeni ürün" }), HttpStatusCode.NoContent);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/services/{service}", serviceRequest with { Name = "Yeni hizmet" }), HttpStatusCode.NoContent);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-type-services/{pair}", pairRequest with { DefaultPrice = 150.50m }), HttpStatusCode.NoContent);
            var updated = await client.GetFromJsonAsync<CatalogProductServicesDto>($"/catalog/product-types/{product}/services");
            var option = Assert.Single(updated!.Services);
            Assert.Equal(pair, option.ProductTypeServiceId);
            Assert.Equal(150.50m, option.DefaultPrice);
            Assert.Equal("Yeni hizmet", option.Name);
            Assert.False(option.IsSelectedByDefault);

            await ExpectAsync(client.PostAsJsonAsync("/catalog/categories", categoryRequest), HttpStatusCode.Conflict);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-type-services", pairRequest), HttpStatusCode.Conflict);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/categories/{category}", categoryRequest with { Code = fixture.CodePrefix + "-changed" }), HttpStatusCode.Conflict);
            await ExpectAsync(client.DeleteAsync($"/catalog/categories/{category}"), HttpStatusCode.Conflict);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/categories/{category}", categoryRequest with { IsActive = false }), HttpStatusCode.Conflict);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-type-services/{pair}", pairRequest with { ServiceId = Guid.NewGuid() }), HttpStatusCode.NotFound);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-type-services/{pair}", pairRequest with { ServiceId = otherService }), HttpStatusCode.Conflict);

            await ExpectAsync(client.PutAsJsonAsync($"/catalog/services/{service}", serviceRequest with { IsActive = false }), HttpStatusCode.NoContent);
            var inactiveOptions = await client.GetFromJsonAsync<CatalogProductServicesDto>($"/catalog/product-types/{product}/services");
            Assert.Empty(inactiveOptions!.Services);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/services/{service}", serviceRequest), HttpStatusCode.NoContent);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-types/{product}", productRequest with { IsActive = false }), HttpStatusCode.NoContent);
            await ExpectAsync(client.GetAsync($"/catalog/product-types/{product}/services"), HttpStatusCode.NotFound);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-type-services/{pair}", pairRequest), HttpStatusCode.NotFound);
            await ExpectAsync(client.PutAsJsonAsync($"/catalog/product-types/{product}", productRequest), HttpStatusCode.NoContent);

            await ExpectAsync(client.DeleteAsync($"/catalog/product-type-services/{pair}"), HttpStatusCode.NoContent);
            await ExpectAsync(client.DeleteAsync($"/catalog/product-type-services/{pair}"), HttpStatusCode.NotFound);
            await ExpectAsync(client.DeleteAsync($"/catalog/product-types/{product}"), HttpStatusCode.NoContent);
            await ExpectAsync(client.DeleteAsync($"/catalog/services/{service}"), HttpStatusCode.NoContent);
            await ExpectAsync(client.DeleteAsync($"/catalog/services/{otherService}"), HttpStatusCode.NoContent);
            await ExpectAsync(client.DeleteAsync($"/catalog/categories/{category}"), HttpStatusCode.NoContent);
            await ExpectAsync(client.GetAsync($"/catalog/categories/{category}"), HttpStatusCode.NotFound);
            await ExpectAsync(client.GetAsync($"/catalog/services/{service}"), HttpStatusCode.NotFound);

            async Task<Guid> CreateAsync<T>(string route, T request)
            {
                using var response = await client.PostAsJsonAsync($"/catalog/{route}", request);
                Assert.True(response.StatusCode == HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
                Assert.NotNull(response.Headers.Location);
                var created = await response.Content.ReadFromJsonAsync<CatalogWriteResult>();
                Assert.NotNull(created);
                Assert.NotEqual(Guid.Empty, created.Id);
                using var read = await client.GetAsync(response.Headers.Location);
                Assert.Equal(HttpStatusCode.OK, read.StatusCode);
                return created.Id;
            }
        }

        [CatalogDatabaseFact]
        public async Task Management_rejects_invalid_data_missing_parents_and_client_controlled_security_fields()
        {
            await using var fixture = await CatalogSecurityFixture.CreateAsync();
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", application.Token(fixture.AdminId.ToString()));
            await ExpectAsync(client.PostAsJsonAsync("/catalog/categories", new { code = " ", name = " " }), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/categories", new { code = fixture.CodePrefix, name = "Test", role = "PlatformAdmin", userId = fixture.CustomerId }), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-types", new CatalogProductTypeWriteRequest(Guid.Empty, fixture.CodePrefix, "Test")), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-types", new CatalogProductTypeWriteRequest(Guid.NewGuid(), fixture.CodePrefix, "Test")), HttpStatusCode.NotFound);
            foreach (var price in new[] { -1m, 1.123m, 10000000000m })
                await ExpectAsync(client.PostAsJsonAsync("/catalog/product-type-services", new CatalogProductTypeServiceWriteRequest(Guid.NewGuid(), Guid.NewGuid(), price, "PIECE", "BASE")), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-type-services", new { productTypeId = Guid.NewGuid(), serviceId = Guid.NewGuid(), defaultPrice = 1, priceUnit = "PIECE", selectionKind = "BASE", isDefaultSelected = true }), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-type-services", new { productTypeId = Guid.NewGuid(), serviceId = Guid.NewGuid(), priceUnit = "PIECE", selectionKind = "BASE" }), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-type-services", new CatalogProductTypeServiceWriteRequest(Guid.NewGuid(), Guid.NewGuid(), 1, "KG", "BASE")), HttpStatusCode.BadRequest);
            await ExpectAsync(client.PostAsJsonAsync("/catalog/product-type-services", new CatalogProductTypeServiceWriteRequest(Guid.NewGuid(), Guid.NewGuid(), 1, "PIECE", "UNKNOWN")), HttpStatusCode.BadRequest);
            await ExpectAsync(client.DeleteAsync($"/catalog/services/{Guid.NewGuid()}"), HttpStatusCode.NotFound);
            await ExpectAsync(client.DeleteAsync($"/catalog/services/{Guid.Empty}"), HttpStatusCode.BadRequest);
        }

        private static async Task ExpectAsync(Task<HttpResponseMessage> request, HttpStatusCode status)
        {
            using var response = await request;
            Assert.True(response.StatusCode == status, $"Beklenen: {(int)status}; dönen: {(int)response.StatusCode}; {await response.Content.ReadAsStringAsync()}");
            if ((int)status >= 400)
                await ProblemResponseAssertions.AssertAsync(response, status,
                    status switch { HttpStatusCode.BadRequest => "validation_failed", HttpStatusCode.NotFound => "resource_not_found", _ => "state_conflict" });
        }
    }
}

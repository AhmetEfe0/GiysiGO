using System.Net;
using System.Net.Http.Json;
using GiysiGo.API.Controllers.Catalog;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using GiysiGo.Modules.Catalog.Application.Repositories;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Hosting;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class CatalogHttpTests
    {
        [Fact]
        public async Task Anonymous_management_is_rejected_without_accessing_the_database()
        {
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
                    new Dictionary<string, string?> { ["ConnectionStrings:GiysiGo"] = null })));
            using var client = application.CreateClient();
            using var response = await client.PostAsJsonAsync("/catalog/categories", new { code = "anonim", name = "Anonim" });
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }

        [Fact]
        public async Task Unexpected_database_or_service_failures_do_not_expose_internal_details()
        {
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.ConfigureLogging(logging => logging.ClearProviders()).ConfigureServices(services =>
                {
                    services.RemoveAll<ICatalogRepository>();
                    services.AddSingleton<ICatalogRepository>(new CatalogControllerTests.FakeCatalogRepository { FailCategoryReads = true });
                }));
            using var client = application.CreateClient();
            using var response = await client.GetAsync("/catalog/categories");
            Assert.Equal(HttpStatusCode.InternalServerError, response.StatusCode);
            var body = await response.Content.ReadAsStringAsync();
            Assert.DoesNotContain("gizli-teknik-ayrinti", body);
            using var json = JsonDocument.Parse(body);
            Assert.Equal("unexpected_error", json.RootElement.GetProperty("code").GetString());
            Assert.False(string.IsNullOrWhiteSpace(json.RootElement.GetProperty("traceId").GetString()));
        }

        [CatalogDatabaseFact]
        public async Task Catalog_routes_read_seeded_data_and_only_valid_product_service_options()
        {
            await using var application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
                    new Dictionary<string, string?>
                    {
                        ["ConnectionStrings:GiysiGo"] = Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")
                    })));
            using var client = application.CreateClient();
            var categories = await client.GetFromJsonAsync<CatalogCategoryDto[]>("/catalog/categories");
            var products = await client.GetFromJsonAsync<CatalogProductTypeDto[]>("/catalog/product-types?pageSize=100");
            Assert.NotNull(categories);
            Assert.NotNull(products);
            Assert.Equal(5, categories.Length);
            Assert.Equal(48, products.Length);
            var trousers = products.Single(product => product.Code == "P006");
            var options = await client.GetFromJsonAsync<CatalogProductServicesDto>($"/catalog/product-types/{trousers.Id}/services");
            Assert.NotNull(options);
            Assert.Equal(trousers.Id, options.ProductTypeId);
            Assert.Equal("none", options.InitialSelection);
            Assert.Equal(1, options.MinimumPrimarySelections);
            Assert.False(options.AddOnsCountTowardMinimum);
            Assert.All(options.Services, option => Assert.False(option.IsSelectedByDefault));
            Assert.Equal(new[] { "S019", "S021", "S022", "S023", "S024", "S025", "S026" },
                options.Services.Select(option => option.Code).Order().ToArray());

            var bedspread = products.Single(product => product.Code == "P039");
            var bedspreadOptions = await client.GetFromJsonAsync<CatalogProductServicesDto>($"/catalog/product-types/{bedspread.Id}/services");
            Assert.NotNull(bedspreadOptions);
            Assert.DoesNotContain(bedspreadOptions.Services, option => option.Code == "S102");

            using var missing = await client.GetAsync($"/catalog/product-types/{Guid.NewGuid()}/services");
            Assert.Equal(HttpStatusCode.NotFound, missing.StatusCode);
        }

        [Theory]
        [InlineData("/catalog/categories")]
        [InlineData("/catalog/product-types")]
        public async Task Public_catalog_routes_require_authentication_for_platform_data_creation(string route)
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            using var response = await client.PostAsJsonAsync(route, new { code = "yetkisiz", name = "Yetkisiz kayıt" });
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }

        [Theory]
        [InlineData(0, 50)]
        [InlineData(1, 0)]
        [InlineData(1, 101)]
        public async Task Invalid_pagination_is_rejected_before_database_access(int pageNumber, int pageSize)
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            using var response = await client.GetAsync($"/catalog/product-types?pageNumber={pageNumber}&pageSize={pageSize}");
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }
    }
}

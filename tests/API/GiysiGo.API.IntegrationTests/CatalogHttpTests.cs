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
            await ProblemResponseAssertions.AssertAsync(response, HttpStatusCode.Unauthorized, "authentication_required");
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
            await ProblemResponseAssertions.AssertAsync(response, HttpStatusCode.InternalServerError, "unexpected_error");
            using var unknown = await client.GetAsync("/catalog/bilinmeyen-yol");
            await ProblemResponseAssertions.AssertAsync(unknown, HttpStatusCode.NotFound, "resource_not_found");
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
            var categoryPage = await client.GetFromJsonAsync<CatalogPageDto<CatalogCategoryDto>>("/catalog/categories");
            var categories = categoryPage!.Items;
            var productPage = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>("/catalog/product-types?pageSize=100");
            var products = productPage!.Items;
            Assert.NotNull(categories);
            Assert.NotNull(products);
            Assert.Equal(5, categories.Count);
            Assert.Equal(5, categoryPage.TotalCount);
            Assert.Equal(48, products.Count);
            Assert.Equal(48, productPage.TotalCount);
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
            await ProblemResponseAssertions.AssertAsync(missing, HttpStatusCode.NotFound, "resource_not_found");
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
        [InlineData(-1, 20)]
        [InlineData(1, 0)]
        [InlineData(1, -1)]
        [InlineData(1, 101)]
        public async Task Invalid_pagination_is_rejected_before_database_access(int pageNumber, int pageSize)
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            using var response = await client.GetAsync($"/catalog/product-types?page={pageNumber}&pageSize={pageSize}");
            await ProblemResponseAssertions.AssertAsync(response, HttpStatusCode.BadRequest, "validation_failed");
            using var categoryResponse = await client.GetAsync($"/catalog/categories?page={pageNumber}&pageSize={pageSize}");
            await ProblemResponseAssertions.AssertAsync(categoryResponse, HttpStatusCode.BadRequest, "validation_failed");
        }

        [CatalogDatabaseFact]
        public async Task Product_pagination_uses_shared_defaults_second_page_total_and_empty_page_contract()
        {
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            var first = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>("/catalog/product-types");
            Assert.NotNull(first);
            Assert.Equal(1, first.Page);
            Assert.Equal(20, first.PageSize);
            Assert.Equal(20, first.Items.Count);
            Assert.Equal(48, first.TotalCount);
            var second = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>("/catalog/product-types?page=2");
            Assert.NotNull(second);
            Assert.Equal(2, second.Page);
            Assert.Equal(20, second.PageSize);
            Assert.Equal(20, second.Items.Count);
            Assert.Equal(first.TotalCount, second.TotalCount);
            Assert.Empty(first.Items.Select(item => item.Id).Intersect(second.Items.Select(item => item.Id)));
            var all = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>("/catalog/product-types?pageSize=100");
            Assert.Equal(all!.Items.Skip(20).Take(20).Select(item => item.Id), second.Items.Select(item => item.Id));
            var empty = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>("/catalog/product-types?page=2147483647&pageSize=100");
            Assert.Empty(empty!.Items);
            Assert.Equal(2147483647, empty.Page);
            Assert.Equal(48, empty.TotalCount);
            var unknown = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>($"/catalog/product-types?categoryId={Guid.NewGuid()}");
            Assert.Empty(unknown!.Items);
            Assert.Equal(0, unknown.TotalCount);
        }

        [CatalogDatabaseFact]
        public async Task Category_pagination_uses_the_same_shared_contract_and_safe_empty_page()
        {
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            var first = await client.GetFromJsonAsync<CatalogPageDto<CatalogCategoryDto>>("/catalog/categories");
            Assert.NotNull(first);
            Assert.Equal(1, first.Page);
            Assert.Equal(20, first.PageSize);
            Assert.Equal(5, first.Items.Count);
            Assert.Equal(5, first.TotalCount);
            var second = await client.GetFromJsonAsync<CatalogPageDto<CatalogCategoryDto>>("/catalog/categories?page=2&pageSize=2");
            Assert.Equal(2, second!.Page);
            Assert.Equal(2, second.PageSize);
            Assert.Equal(5, second.TotalCount);
            Assert.Equal(first.Items.Skip(2).Take(2).Select(item => item.Id), second.Items.Select(item => item.Id));
            var empty = await client.GetFromJsonAsync<CatalogPageDto<CatalogCategoryDto>>("/catalog/categories?page=2147483647&pageSize=100");
            Assert.Empty(empty!.Items);
            Assert.Equal(5, empty.TotalCount);
            foreach (var route in new[] { "categories", "product-types" })
            {
                using var response = await client.GetAsync($"/catalog/{route}");
                using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
                Assert.Equal(new[] { "items", "page", "pageSize", "totalCount" },
                    json.RootElement.EnumerateObject().Select(property => property.Name).Order(StringComparer.Ordinal));
            }
        }

        [Theory]
        [InlineData("page=abc")]
        [InlineData("pageSize=abc")]
        [InlineData("page=2147483648")]
        public async Task Malformed_pagination_is_rejected_before_database_access(string query)
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            foreach (var route in new[] { "categories", "product-types" })
            {
                using var response = await client.GetAsync($"/catalog/{route}?{query}");
                await ProblemResponseAssertions.AssertAsync(response, HttpStatusCode.BadRequest, "validation_failed");
            }
        }

        [CatalogDatabaseFact]
        public async Task Product_lists_exclude_active_children_of_inactive_and_deleted_categories_with_and_without_filter()
        {
            var categoryId = Guid.NewGuid();
            var prefix = "catalog-list-" + categoryId.ToString("N");
            var factory = new GiysiGo.BuildingBlocks.Infrastructure.SqlConnectionFactory(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
            await using var connection = await factory.OpenAsync();
            var fixture = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "CatalogProductListFixture.sql"));
            await using var application = new CatalogSecurityApplication();
            using var client = application.CreateClient();
            try
            {
                await ExecuteAsync("CREATE");
                var visible = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>($"/catalog/product-types?categoryId={categoryId}&page=2&pageSize=2");
                Assert.Equal(4, visible!.TotalCount);
                Assert.Equal(2, visible.Items.Count);
                Assert.All(visible.Items, product => Assert.Equal(categoryId, product.CategoryId));
                foreach (var operation in new[] { "HIDE_INACTIVE", "HIDE_DELETED" })
                {
                    await ExecuteAsync(operation);
                    var filtered = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>($"/catalog/product-types?categoryId={categoryId}");
                    Assert.Empty(filtered!.Items);
                    Assert.Equal(0, filtered.TotalCount);
                    var unfiltered = await client.GetFromJsonAsync<CatalogPageDto<CatalogProductTypeDto>>("/catalog/product-types?pageSize=100");
                    Assert.Equal(48, unfiltered!.TotalCount);
                    Assert.Equal(48, unfiltered.Items.Count);
                    Assert.DoesNotContain(unfiltered.Items, product => product.CategoryId == categoryId);
                    // Çocuk ürünler aktif kalır; görünmezlik kategori filtresinden kaynaklanır.
                    var activeChildren = await Dapper.SqlMapper.ExecuteScalarAsync<int>(connection,
                        "SELECT COUNT(*) FROM catalog.product_types WHERE category_id = @CategoryId AND is_active = 1 AND delete_date IS NULL;", new { CategoryId = categoryId });
                    Assert.Equal(4, activeChildren);
                }
            }
            finally { await ExecuteAsync("CLEANUP"); }

            Task ExecuteAsync(string operation) => Dapper.SqlMapper.ExecuteAsync(connection, fixture,
                new { Operation = operation, CategoryId = categoryId, Prefix = prefix });
        }
    }
}

using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using GiysiGo.API.Controllers.Catalog;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class CatalogOpenApiTests
    {
        [Fact]
        public async Task Every_catalog_route_and_permission_matches_the_shared_document()
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            using var document = ReadContract();
            var paths = document.RootElement.GetProperty("paths");
            var actions = application.Services.GetRequiredService<IActionDescriptorCollectionProvider>().ActionDescriptors.Items
                .OfType<ControllerActionDescriptor>().Where(action => action.ControllerTypeInfo.Namespace == typeof(CatalogController).Namespace).ToArray();
            var runtimeRoutes = new List<string>();
            foreach (var action in actions)
            {
                var path = "/" + Regex.Replace(action.AttributeRouteInfo!.Template!, @":[^}]+", "");
                var method = action.MethodInfo.GetCustomAttributes<HttpMethodAttribute>().Single().HttpMethods.Single().ToLowerInvariant();
                runtimeRoutes.Add(method + " " + path);
                var operation = paths.GetProperty(path).GetProperty(method);
                Assert.Equal("implemented", operation.GetProperty("x-implementation-status").GetString());
                var anonymous = action.ControllerTypeInfo.GetCustomAttribute<AllowAnonymousAttribute>() is not null;
                if (anonymous) Assert.Equal(0, operation.GetProperty("security").GetArrayLength());
                else
                {
                    Assert.True(operation.GetProperty("security")[0].TryGetProperty("bearerAuth", out _));
                    Assert.Equal(action.ControllerTypeInfo.GetCustomAttribute<AuthorizeAttribute>()!.Policy,
                        operation.GetProperty("x-required-permission").GetString());
                    Assert.Equal("GLOBAL", operation.GetProperty("x-permission-scope").GetString());
                }
                var success = method == "get" ? "200" : method == "post" ? "201" : "204";
                Assert.True(operation.GetProperty("responses").TryGetProperty(success, out _));
            }
            var documentedRoutes = paths.EnumerateObject().Where(path => path.Name.StartsWith("/catalog/", StringComparison.Ordinal))
                .SelectMany(path => path.Value.EnumerateObject().Select(method => method.Name + " " + path.Name));
            Assert.Equal(18, runtimeRoutes.Count);
            Assert.Equal(runtimeRoutes.Order(), documentedRoutes.Order());
        }

        [Fact]
        public void Catalog_dto_properties_match_the_documented_schemas()
        {
            using var document = ReadContract();
            var schemas = document.RootElement.GetProperty("components").GetProperty("schemas");
            var models = new Dictionary<string, Type>
            {
                ["CatalogCategory"] = typeof(CatalogCategoryDto), ["CatalogProductType"] = typeof(CatalogProductTypeDto),
                ["CatalogService"] = typeof(CatalogServiceDto), ["CatalogCategoryPage"] = typeof(CatalogPageDto<CatalogCategoryDto>),
                ["CatalogProductTypePage"] = typeof(CatalogPageDto<CatalogProductTypeDto>),
                ["CatalogProductServices"] = typeof(CatalogProductServicesDto), ["CatalogServiceOption"] = typeof(CatalogServiceOptionDto),
                ["CatalogCategoryWriteRequest"] = typeof(CatalogCategoryWriteRequest), ["CatalogProductTypeWriteRequest"] = typeof(CatalogProductTypeWriteRequest),
                ["CatalogServiceWriteRequest"] = typeof(CatalogServiceWriteRequest), ["CatalogPairWriteRequest"] = typeof(CatalogProductTypeServiceWriteRequest),
                ["IdResult"] = typeof(CatalogWriteResult)
            };
            foreach (var (name, model) in models)
            {
                var properties = model.GetProperties().Select(property => property.GetCustomAttribute<JsonPropertyNameAttribute>()?.Name
                    ?? JsonNamingPolicy.CamelCase.ConvertName(property.Name));
                Assert.Equal(properties.Order(), schemas.GetProperty(name).GetProperty("properties").EnumerateObject().Select(property => property.Name).Order());
            }
        }

        private static JsonDocument ReadContract() => JsonDocument.Parse(File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "mvp-contracts.json")));
    }
}

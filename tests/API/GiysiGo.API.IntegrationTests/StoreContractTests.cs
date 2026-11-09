using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using GiysiGo.API.Controllers.Stores;
using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreContractTests
    {
        [Theory]
        [InlineData("GET", "/corporates/gecersiz/stores", 404)]
        [InlineData("DELETE", "/corporates/11111111-1111-1111-1111-111111111111/stores/22222222-2222-2222-2222-222222222222", 405)]
        public async Task Unmatched_store_routes_use_complete_problem_details(string method, string path, int status)
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            using var request = new HttpRequestMessage(new HttpMethod(method), path);
            using var response = await client.SendAsync(request);
            Assert.Equal(status, (int)response.StatusCode);
            Assert.Equal("application/problem+json",response.Content.Headers.ContentType?.MediaType);
            using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            foreach (var property in new[] { "type","title","detail","instance","code","traceId" })
                Assert.False(string.IsNullOrWhiteSpace(document.RootElement.GetProperty(property).GetString()));
        }
        [Theory]
        [InlineData("tr-TR")]
        [InlineData("en-US")]
        public void Valid_store_request_passes_data_annotation_validation(string culture)
        {
            var previous = System.Globalization.CultureInfo.CurrentCulture;
            try
            {
                System.Globalization.CultureInfo.CurrentCulture = System.Globalization.CultureInfo.GetCultureInfo(culture);
                var request = new StoreWriteRequest { Name = "Merkez", AddressText = "Örnek adres", Latitude = 41, Longitude = 29, ServiceRadiusKm = 0.01m };
                var results = new List<System.ComponentModel.DataAnnotations.ValidationResult>();
                Assert.True(System.ComponentModel.DataAnnotations.Validator.TryValidateObject(request, new(request), results, true), string.Join("; ",results));
            }
            finally { System.Globalization.CultureInfo.CurrentCulture = previous; }
        }
        [Fact]
        public async Task Store_routes_permissions_and_shared_pagination_match_openapi()
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();
            using var document = JsonDocument.Parse(File.ReadAllText(Path.Combine(AppContext.BaseDirectory,"mvp-contracts.json")));
            var paths = document.RootElement.GetProperty("paths");
            var actions = application.Services.GetRequiredService<IActionDescriptorCollectionProvider>().ActionDescriptors.Items
                .OfType<ControllerActionDescriptor>().Where(action => action.ControllerTypeInfo == typeof(StoresController).GetTypeInfo()).ToArray();
            Assert.Equal(5, actions.Length);
            foreach (var action in actions)
            {
                var path = "/" + Regex.Replace(action.AttributeRouteInfo!.Template!, @":[^}]+", "");
                var method = action.MethodInfo.GetCustomAttributes<HttpMethodAttribute>().Single().HttpMethods.Single().ToLowerInvariant();
                var operation = paths.GetProperty(path).GetProperty(method);
                Assert.Equal("implemented", operation.GetProperty("x-implementation-status").GetString());
                Assert.True(operation.GetProperty("security")[0].TryGetProperty("bearerAuth", out _));
                if (method is "post" or "put" or "patch")
                {
                    Assert.Equal(PermissionCodes.StoreManage, action.MethodInfo.GetCustomAttribute<AuthorizeAttribute>()!.Policy);
                    Assert.Equal(PermissionCodes.StoreManage, operation.GetProperty("x-required-permission").GetString());
                }
                if (action.ActionName == "List")
                {
                    var parameters = operation.GetProperty("parameters").EnumerateArray().ToDictionary(parameter => parameter.GetProperty("name").GetString()!);
                    Assert.Equal(1, parameters["page"].GetProperty("schema").GetProperty("default").GetInt32());
                    Assert.Equal(20, parameters["pageSize"].GetProperty("schema").GetProperty("default").GetInt32());
                    Assert.Equal(100, parameters["pageSize"].GetProperty("schema").GetProperty("maximum").GetInt32());
                }
            }
        }

        [Fact]
        public void Store_dto_fields_and_required_measurements_match_openapi()
        {
            using var document = JsonDocument.Parse(File.ReadAllText(Path.Combine(AppContext.BaseDirectory,"mvp-contracts.json")));
            var schemas = document.RootElement.GetProperty("components").GetProperty("schemas");
            foreach (var model in new Dictionary<string,Type>
            {
                ["ManagedStore"] = typeof(StoreDto), ["ManagedStorePage"] = typeof(StorePageDto),
                ["StoreWriteRequest"] = typeof(StoreWriteRequest), ["StoreActiveRequest"] = typeof(StoreActiveRequest)
            })
            {
                Assert.Equal(model.Value.GetProperties().Select(property => JsonNamingPolicy.CamelCase.ConvertName(property.Name)).Order(),
                    schemas.GetProperty(model.Key).GetProperty("properties").EnumerateObject().Select(property => property.Name).Order());
            }
            foreach (var property in new[] { "Latitude", "Longitude", "ServiceRadiusKm" })
                Assert.NotNull(typeof(StoreWriteRequest).GetProperty(property)!.GetCustomAttribute<JsonRequiredAttribute>());
            Assert.NotNull(typeof(StoreActiveRequest).GetProperty("IsActive")!.GetCustomAttribute<JsonRequiredAttribute>());
            var request = schemas.GetProperty("StoreWriteRequest");
            Assert.False(request.GetProperty("additionalProperties").GetBoolean());
            foreach (var forbidden in new[] { "corporateId", "userId", "id", "isActive", "createDate", "deleteDate" })
                Assert.False(request.GetProperty("properties").TryGetProperty(forbidden, out _));
        }
    }
}

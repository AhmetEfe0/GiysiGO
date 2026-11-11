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
    public sealed class StoreOfferingContractTests
    {
        [Fact]
        public async Task Offering_routes_match_documented_store_permissions_and_responses()
        {
            await using var app = new WebApplicationFactory<Program>();
            using var client = app.CreateClient();
            using var contract = JsonDocument.Parse(File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "mvp-contracts.json")));
            var actions = app.Services.GetRequiredService<IActionDescriptorCollectionProvider>().ActionDescriptors.Items
                .OfType<ControllerActionDescriptor>().Where(action => action.ControllerTypeInfo == typeof(StoreOfferingsController).GetTypeInfo()).ToArray();
            Assert.Equal(4, actions.Length);
            Assert.Equal(PermissionCodes.StoreOfferingManage, typeof(StoreOfferingsController).GetCustomAttribute<AuthorizeAttribute>()?.Policy);
            foreach (var action in actions)
            {
                var path = "/" + Regex.Replace(action.AttributeRouteInfo!.Template!, @":[^}]+", "");
                var method = action.MethodInfo.GetCustomAttributes<HttpMethodAttribute>().Single().HttpMethods.Single().ToLowerInvariant();
                var operation = contract.RootElement.GetProperty("paths").GetProperty(path).GetProperty(method);
                Assert.Equal("implemented", operation.GetProperty("x-implementation-status").GetString());
                Assert.Equal("STORE", operation.GetProperty("x-permission-scope").GetString());
                Assert.Equal(PermissionCodes.StoreOfferingManage, operation.GetProperty("x-required-permission").GetString());
                Assert.True(operation.GetProperty("responses").TryGetProperty(method == "get" ? "200" : "204", out _));
                using var response = await client.SendAsync(new HttpRequestMessage(new HttpMethod(method), path.Replace("{corporateId}", Guid.NewGuid().ToString()).Replace("{storeId}", Guid.NewGuid().ToString()).Replace("{combinationId}", Guid.NewGuid().ToString())));
                Assert.Equal(System.Net.HttpStatusCode.Unauthorized, response.StatusCode);
            }
        }

        [Theory]
        [InlineData("1e-100")]
        [InlineData("1.00000000000000000000000000001")]
        [InlineData("9999999999.9900000000000000001")]
        public void Prices_must_not_silently_round_during_json_binding(string number)
        {
            var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
            var priceBody = "{\"priceOverride\":" + number + "}";
            var saveBody = "{\"isActive\":true,\"priceOverride\":" + number + "}";
            Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<OfferingPriceRequest>(priceBody, options));
            Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<OfferingWriteRequest>(saveBody, options));
        }

        [Fact]
        public void Offering_list_documents_the_shared_pagination_shape()
        {
            using var contract = JsonDocument.Parse(File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "mvp-contracts.json")));
            var schema = contract.RootElement.GetProperty("components").GetProperty("schemas").GetProperty("ManagedOfferingPage");
            foreach (var name in new[] { "items", "page", "pageSize", "totalCount" })
            {
                Assert.True(schema.GetProperty("properties").TryGetProperty(name, out _));
                Assert.Contains(schema.GetProperty("required").EnumerateArray(), value => value.GetString() == name);
            }
            var response = contract.RootElement.GetProperty("paths").GetProperty("/corporates/{corporateId}/stores/{storeId}/offerings")
                .GetProperty("get").GetProperty("responses").GetProperty("200").GetProperty("content").GetProperty("application/json").GetProperty("schema");
            Assert.Equal("#/components/schemas/ManagedOfferingPage", response.GetProperty("$ref").GetString());
        }

        [Fact]
        public void Price_reset_requires_explicit_null_and_rejects_unmapped_fields()
        {
            var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
            Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<OfferingPriceRequest>("{}", options));
            Assert.Null(JsonSerializer.Deserialize<OfferingPriceRequest>("{\"priceOverride\":null}", options)!.PriceOverride);
            Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<OfferingPriceRequest>("{\"priceOverride\":null,\"currency\":\"USD\"}", options));
            Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<OfferingWriteRequest>("{\"priceOverride\":null}", options));
        }
    }
}

using Microsoft.AspNetCore.Mvc.Testing;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class ApiHostTests
    {
        [Fact]
        public async Task Health_endpoint_is_available()
        {
            await using var application = new WebApplicationFactory<Program>();
            using var client = application.CreateClient();

            using var response = await client.GetAsync("/health");

            Assert.True(response.IsSuccessStatusCode);
        }
    }
}

using System.Net;
using System.Text.Json;

namespace GiysiGo.API.IntegrationTests
{
    internal static class ProblemResponseAssertions
    {
        public static async Task AssertAsync(HttpResponseMessage response, HttpStatusCode status, string code)
        {
            Assert.Equal(status, response.StatusCode);
            Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
            var body = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(body);
            var problem = document.RootElement;
            foreach (var field in new[] { "type", "title", "detail", "instance", "code", "traceId" })
                Assert.False(string.IsNullOrWhiteSpace(problem.GetProperty(field).GetString()), $"Eksik hata alanı: {field}");
            Assert.Equal((int)status, problem.GetProperty("status").GetInt32());
            Assert.Equal(code, problem.GetProperty("code").GetString());
            Assert.Equal(response.RequestMessage!.RequestUri!.AbsolutePath, problem.GetProperty("instance").GetString());
            if (status == HttpStatusCode.BadRequest)
                Assert.Equal(JsonValueKind.Object, problem.GetProperty("errors").ValueKind);
            Assert.DoesNotContain("SqlException", body);
            Assert.DoesNotContain("StackTrace", body);
        }
    }
}

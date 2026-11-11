using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using GiysiGo.API.Controllers.Stores;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreNumberBoundaryTests
    {
        [Theory]
        [InlineData("90.00000000000000000000000000001")]
        [InlineData("1e-100")]
        public void Measurements_must_not_silently_round_during_json_read(string latitude)
        {
            var json = "{\"name\":\"Ad\",\"addressText\":\"Adres\",\"latitude\":" + latitude + ",\"longitude\":29,\"serviceRadiusKm\":5}";
            Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<StoreWriteRequest>(json, new JsonSerializerOptions(JsonSerializerDefaults.Web)));
        }

        [Theory]
        [InlineData("4.1e1", "41")]
        [InlineData("-4.100000e1", "-41")]
        [InlineData("0.00000100", "0.000001")]
        [InlineData("-0e10", "0")]
        [InlineData("90.00000000000000000000000000000", "90")]
        public void Exact_measurements_preserve_value(string number, string expected)
        {
            var options = new JsonSerializerOptions();
            options.Converters.Add(new ExactDecimalConverter());
            var value = JsonSerializer.Deserialize<decimal>(number, options);
            Assert.Equal(decimal.Parse(expected, System.Globalization.CultureInfo.InvariantCulture), value);
            Assert.Equal(value, JsonSerializer.Deserialize<decimal>(JsonSerializer.Serialize(value, options), options));
        }

        [StoreSqlFact]
        public async Task Raw_measurements_reject_lost_precision_and_accept_exact_scientific_numbers()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var path = StoreTestDatabase.Path(corporate);
            foreach (var values in new[]
            {
                ("90.00000000000000000000000000001", "29", "5"),
                ("41", "1e-100", "5"),
                ("41", "29", "5.00000000000000000000000000001")
            })
            {
                using var content = new StringContent("{\"name\":\"Ad\",\"addressText\":\"Adres\",\"latitude\":" + values.Item1 + ",\"longitude\":" + values.Item2 + ",\"serviceRadiusKm\":" + values.Item3 + "}", Encoding.UTF8, "application/json");
                using var rejected = await db.Client.PostAsync(path, content);
                Assert.Equal(HttpStatusCode.BadRequest, rejected.StatusCode);
            }
            using var list = await db.Client.GetAsync(path);
            Assert.Equal(0, (await list.Content.ReadFromJsonAsync<StorePageDto>())!.TotalCount);
            using var exact = new StringContent("{\"name\":\"Ad\",\"addressText\":\"Adres\",\"latitude\":4.1e1,\"longitude\":2.900e1,\"serviceRadiusKm\":5e0}", Encoding.UTF8, "application/json");
            using var created = await db.Client.PostAsync(path, exact);
            Assert.Equal(HttpStatusCode.Created, created.StatusCode);
        }
    }
}

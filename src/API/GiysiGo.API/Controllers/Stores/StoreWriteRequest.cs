using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using GiysiGo.Modules.Catalog.Application.Stores;

namespace GiysiGo.API.Controllers.Stores
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed class StoreWriteRequest
    {
        [Required, MaxLength(200)] public string Name { get; init; } = string.Empty;
        [Required, MaxLength(2000)] public string AddressText { get; init; } = string.Empty;
        [JsonConverter(typeof(ExactDecimalConverter))]
        [JsonRequired, Range(typeof(decimal), "-90", "90", ParseLimitsInInvariantCulture = true, ConvertValueInInvariantCulture = true)] public decimal Latitude { get; init; }
        [JsonConverter(typeof(ExactDecimalConverter))]
        [JsonRequired, Range(typeof(decimal), "-180", "180", ParseLimitsInInvariantCulture = true, ConvertValueInInvariantCulture = true)] public decimal Longitude { get; init; }
        [JsonConverter(typeof(ExactDecimalConverter))]
        [JsonRequired, Range(typeof(decimal), "0.01", "99999.99", ParseLimitsInInvariantCulture = true, ConvertValueInInvariantCulture = true)] public decimal ServiceRadiusKm { get; init; }
        public StoreWriteData ToData() => new(Name, AddressText, Latitude, Longitude, ServiceRadiusKm);
    }
}

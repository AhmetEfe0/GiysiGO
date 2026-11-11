using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Stores
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record OfferingWriteRequest([property: JsonRequired] bool IsActive, [property: JsonRequired, JsonConverter(typeof(ExactDecimalConverter))] decimal? PriceOverride);
}

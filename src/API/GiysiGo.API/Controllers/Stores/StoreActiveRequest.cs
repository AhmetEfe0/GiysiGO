using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Stores
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed class StoreActiveRequest
    {
        [JsonRequired] public bool IsActive { get; init; }
    }
}

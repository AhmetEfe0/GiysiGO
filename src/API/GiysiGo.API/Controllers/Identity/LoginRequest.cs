using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Identity
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record LoginRequest(string Email, string Password);
}

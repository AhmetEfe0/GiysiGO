using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Identity
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record RegisterRequest(string Email, string Password);
}

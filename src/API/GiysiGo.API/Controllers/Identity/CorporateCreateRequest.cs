using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Identity
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record CorporateCreateRequest([Required, MaxLength(200)] string Name);
}

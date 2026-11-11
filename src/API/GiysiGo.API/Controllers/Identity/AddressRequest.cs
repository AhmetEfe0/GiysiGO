using GiysiGo.Modules.Identity.Application.Models;
using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Identity
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record AddressRequest(string? Label, string? AddressText, decimal? Latitude,
        decimal? Longitude, string? ContactName, string? ContactPhone)
    {
        public CustomerAddressInput ToInput()
        {
            if (Latitude is null) throw new ArgumentException("Latitude is required.", nameof(Latitude));
            if (Longitude is null) throw new ArgumentException("Longitude is required.", nameof(Longitude));
            return new CustomerAddressInput(Label ?? string.Empty, AddressText ?? string.Empty,
                Latitude.Value, Longitude.Value, ContactName ?? string.Empty, ContactPhone ?? string.Empty);
        }
    }
}

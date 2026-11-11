namespace GiysiGo.Modules.Identity.Application.Models
{
    public sealed record CustomerAddressInput(string Label, string AddressText, decimal Latitude,
        decimal Longitude, string ContactName, string ContactPhone);
}

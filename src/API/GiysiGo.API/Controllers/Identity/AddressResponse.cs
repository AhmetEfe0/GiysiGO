using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.API.Controllers.Identity
{
    public sealed record AddressResponse(Guid Id, string Label, string AddressText, decimal Latitude,
        decimal Longitude, string ContactName, string ContactPhone)
    {
        public static AddressResponse From(CustomerAddress address)
            => new(address.Id, address.Label, address.AddressText, address.Latitude,
                address.Longitude, address.ContactName, address.ContactPhone);
    }
}

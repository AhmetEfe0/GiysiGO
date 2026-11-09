using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.API.Controllers.Stores
{
    public sealed record StoreDto(Guid Id, Guid CorporateId, string Name, string AddressText, decimal Latitude, decimal Longitude, decimal ServiceRadiusKm, bool IsActive)
    {
        public static StoreDto From(Store store) => new(store.Id, store.CorporateId, store.Name, store.AddressText, store.Latitude, store.Longitude, store.ServiceRadiusKm, store.IsActive);
    }
}

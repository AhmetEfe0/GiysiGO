namespace GiysiGo.Modules.Catalog.Application.Stores
{
    public sealed record StoreWriteData(string Name, string AddressText, decimal Latitude, decimal Longitude, decimal ServiceRadiusKm);
}

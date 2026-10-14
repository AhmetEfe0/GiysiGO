namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public sealed record StoreLocationSnapshot(Guid StoreId, string AddressText, decimal Latitude, decimal Longitude, bool IsActive);
}

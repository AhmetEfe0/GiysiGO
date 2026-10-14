namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public sealed record CustomerAddressSnapshot(Guid Id, Guid CustomerId, string AddressText, decimal Latitude, decimal Longitude, string ContactName, string ContactPhone);
}

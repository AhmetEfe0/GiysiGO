namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public sealed record OrderPickupSnapshot(
        Guid OrderId,
        Guid StoreId,
        string PickupAddressText,
        decimal PickupLatitude,
        decimal PickupLongitude,
        string ContactName,
        string ContactPhone,
        int RequiredCapacityUnits,
        DateTime PickupWindowStartUtc,
        DateTime PickupWindowEndUtc);
}

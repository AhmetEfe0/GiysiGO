namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public sealed record OrderPickupSnapshot(Guid OrderId, Guid StoreId, decimal PickupLatitude, decimal PickupLongitude, DateTime PickupWindowStartUtc, DateTime PickupWindowEndUtc);
}

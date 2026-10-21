namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record CheckoutContext(Guid CartId, Guid CustomerId, Guid StoreId, Guid AddressId, decimal Latitude, decimal Longitude, DateTime PickupWindowStartUtc, DateTime PickupWindowEndUtc);
}

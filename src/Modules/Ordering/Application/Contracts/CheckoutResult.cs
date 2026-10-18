namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record CheckoutResult(Guid OrderId, Guid SourceCartId, Guid StoreId, DateTime PickupWindowStartUtc, DateTime PickupWindowEndUtc, bool Created);
}

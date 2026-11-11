namespace GiysiGo.API.Controllers.Ordering
{
    public sealed record CreateCartRequest(
        [NotEmptyGuid] Guid StoreId,
        [NotEmptyGuid] Guid AddressId,
        DateTime? PickupWindowStartUtc,
        DateTime? PickupWindowEndUtc);
}

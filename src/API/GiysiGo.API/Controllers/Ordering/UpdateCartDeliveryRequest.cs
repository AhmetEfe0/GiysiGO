using System.ComponentModel.DataAnnotations;

namespace GiysiGo.API.Controllers.Ordering
{
    public sealed record UpdateCartDeliveryRequest(
        [NotEmptyGuid] Guid AddressId,
        DateTime? PickupWindowStartUtc,
        DateTime? PickupWindowEndUtc,
        [Range(0, int.MaxValue)] int ExpectedCartVersion);
}

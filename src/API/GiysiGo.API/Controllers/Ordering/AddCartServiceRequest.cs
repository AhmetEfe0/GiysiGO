using System.ComponentModel.DataAnnotations;

namespace GiysiGo.API.Controllers.Ordering
{
    public sealed record AddCartServiceRequest(
        [NotEmptyGuid] Guid StoreOfferingId,
        [NotEmptyGuid] Guid ServiceId,
        [Range(0, int.MaxValue)] int ExpectedCartVersion);
}

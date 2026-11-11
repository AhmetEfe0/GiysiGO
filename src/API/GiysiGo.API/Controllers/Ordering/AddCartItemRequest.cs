using System.ComponentModel.DataAnnotations;

namespace GiysiGo.API.Controllers.Ordering
{
    public sealed record AddCartItemRequest(
        [NotEmptyGuid] Guid ProductTypeId,
        string? CustomerNote,
        [Range(typeof(decimal), "0.001", "999999999.999", ParseLimitsInInvariantCulture = true)] decimal? CustomerMeasurement,
        [Range(0, int.MaxValue)] int ExpectedCartVersion);
}

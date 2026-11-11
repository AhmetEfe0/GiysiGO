namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record CartEstimateResult(IReadOnlyList<CartEstimateLine> Lines, decimal? Total, string Currency, bool IsEstimate, bool IsComplete);
}

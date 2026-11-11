namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record CartEstimateLine(Guid CartItemId, Guid ServiceId, decimal UnitPrice, string PriceUnit, decimal? Quantity, decimal? Amount);
}

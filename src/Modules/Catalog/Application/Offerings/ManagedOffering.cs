namespace GiysiGo.Modules.Catalog.Application.Offerings
{
    public sealed record ManagedOffering(Guid Id, Guid ProductTypeServiceId, decimal? PriceOverride,
        decimal DefaultPrice, decimal UnitPrice, string Currency, string PriceUnit, bool IsActive);
}

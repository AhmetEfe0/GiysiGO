namespace GiysiGo.API.Controllers.Catalog
{
    public sealed record CatalogServiceOptionDto(
        Guid ProductTypeServiceId,
        Guid ServiceId,
        string Code,
        string Name,
        decimal DefaultPrice,
        string Currency,
        string PriceUnit,
        string SelectionKind,
        bool IsSelectedByDefault);
}

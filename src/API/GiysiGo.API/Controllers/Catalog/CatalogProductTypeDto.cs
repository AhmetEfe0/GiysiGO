namespace GiysiGo.API.Controllers.Catalog
{
    public sealed record CatalogProductTypeDto(Guid Id, Guid CategoryId, string Code, string Name, string BaseUnit);
}

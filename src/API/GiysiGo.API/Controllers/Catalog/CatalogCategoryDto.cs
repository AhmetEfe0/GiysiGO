namespace GiysiGo.API.Controllers.Catalog
{
    public sealed record CatalogCategoryDto(Guid Id, string Code, string Name, int SortOrder);
}

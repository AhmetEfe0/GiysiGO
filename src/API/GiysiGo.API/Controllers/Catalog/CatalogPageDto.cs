namespace GiysiGo.API.Controllers.Catalog
{
    public sealed record CatalogPageDto<T>(IReadOnlyList<T> Items, int Page, int PageSize, int TotalCount);
}

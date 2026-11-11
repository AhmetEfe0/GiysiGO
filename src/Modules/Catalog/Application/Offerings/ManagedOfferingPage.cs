namespace GiysiGo.Modules.Catalog.Application.Offerings
{
    public sealed record ManagedOfferingPage(IReadOnlyList<ManagedOffering> Items, int Page, int PageSize, long TotalCount);
}

using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Application.Stores
{
    public sealed record StorePage(IReadOnlyList<Store> Items, int Page, int PageSize, long TotalCount);
}

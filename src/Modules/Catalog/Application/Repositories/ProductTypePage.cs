using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Application.Repositories
{
    public sealed record ProductTypePage(IReadOnlyList<ProductType> Items, int TotalCount);
}

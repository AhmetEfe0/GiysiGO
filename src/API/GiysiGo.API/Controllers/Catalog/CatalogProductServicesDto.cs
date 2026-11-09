namespace GiysiGo.API.Controllers.Catalog
{
    public sealed record CatalogProductServicesDto(
        Guid ProductTypeId,
        string InitialSelection,
        int MinimumPrimarySelections,
        bool AddOnsCountTowardMinimum,
        IReadOnlyList<CatalogServiceOptionDto> Services);
}

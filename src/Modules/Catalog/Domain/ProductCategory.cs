using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Catalog.Domain
{
    public class ProductCategory : EntityBase<Guid>
    {
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
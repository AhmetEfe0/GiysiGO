using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Catalog.Domain
{
    public class ProductType : EntityBase<Guid>
    {
        public Guid CategoryId { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string BaseUnit { get; set; } = "PIECE";
        public bool IsActive { get; set; } = true;
    }
}
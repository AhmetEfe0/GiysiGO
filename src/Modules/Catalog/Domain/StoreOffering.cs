using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Catalog.Domain
{
    public class StoreOffering : EntityBase<Guid>
    {
        public Guid StoreId { get; set; }
        public Guid ProductTypeServiceId { get; set; }
        public decimal? PriceOverride { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Catalog.Domain
{
    public class ProductTypeService : EntityBase<Guid>
    {
        public Guid ProductTypeId { get; set; }
        public Guid ServiceId { get; set; }
        public decimal DefaultPrice { get; set; }
        public string Currency { get; set; } = "TRY";
        public string PriceUnit { get; set; } = "PIECE";
        public string SelectionKind { get; set; } = "BASE";
        public bool IsDefaultSelected { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Catalog.Domain
{
    public class Store : EntityBase<Guid>
    {
        public Guid CorporateId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string AddressText { get; set; } = string.Empty;
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public decimal ServiceRadiusKm { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
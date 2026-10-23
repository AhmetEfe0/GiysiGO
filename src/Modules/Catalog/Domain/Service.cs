using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Catalog.Domain
{
    public class Service : EntityBase<Guid>
    {
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}
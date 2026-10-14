namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public sealed record StoreOfferingSnapshot(Guid StoreId, Guid ProductTypeId, Guid ServiceId, decimal UnitPrice, string PriceUnit, bool IsActive);
}

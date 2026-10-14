namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface IStoreCatalogReader
    {
        Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, CancellationToken cancellationToken = default);
        Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, CancellationToken cancellationToken = default);
        Task<bool> ServesLocationAsync(Guid storeId, decimal latitude, decimal longitude, CancellationToken cancellationToken = default);
    }
}

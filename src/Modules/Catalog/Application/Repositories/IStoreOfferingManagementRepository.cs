using GiysiGo.Modules.Catalog.Application.Offerings;

namespace GiysiGo.Modules.Catalog.Application.Repositories
{
    public interface IStoreOfferingManagementRepository
    {
        Task<ManagedOfferingPage> ListAsync(Guid corporateId, Guid storeId, int page, int pageSize, CancellationToken token);
        Task<Guid> WriteAsync(Guid corporateId, Guid storeId, Guid combinationId, string operation, bool? isActive, decimal? priceOverride, CancellationToken token);
    }
}

using GiysiGo.Modules.Catalog.Application.Stores;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Application.Repositories
{
    public interface IStoreManagementRepository
    {
        Task<StorePage> GetPageAsync(Guid corporateId, bool includeInactive, int page, int pageSize, CancellationToken cancellationToken);
        Task<Store?> GetAsync(Guid corporateId, Guid id, CancellationToken cancellationToken);
        Task<Guid> SaveAsync(Guid corporateId, Guid id, StoreWriteData data, bool create, CancellationToken cancellationToken);
        Task SetActiveAsync(Guid corporateId, Guid id, bool isActive, CancellationToken cancellationToken);
    }
}

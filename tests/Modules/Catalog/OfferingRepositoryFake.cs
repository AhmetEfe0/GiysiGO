using GiysiGo.Modules.Catalog.Application.Offerings;
using GiysiGo.Modules.Catalog.Application.Repositories;
namespace GiysiGo.Modules.Catalog.Tests
{
    internal sealed class OfferingRepositoryFake : IStoreOfferingManagementRepository
    {
        public int Calls { get; private set; }
        public string? Operation { get; private set; }
        public decimal? Price { get; private set; }
        public bool? Active { get; private set; }
        public Task<ManagedOfferingPage> ListAsync(Guid corporateId, Guid storeId, int page, int pageSize, CancellationToken token)
        {
            Calls++; return Task.FromResult(new ManagedOfferingPage([], page, pageSize, 0));
        }
        public Task<Guid> WriteAsync(Guid corporateId, Guid storeId, Guid combinationId, string operation, bool? isActive, decimal? priceOverride, CancellationToken token)
        {
            Calls++; Operation = operation; Price = priceOverride; Active = isActive; return Task.FromResult(Guid.NewGuid());
        }
    }
}

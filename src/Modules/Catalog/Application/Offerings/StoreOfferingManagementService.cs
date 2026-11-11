using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Repositories;

namespace GiysiGo.Modules.Catalog.Application.Offerings
{
    public sealed class StoreOfferingManagementService(ICurrentUser user, IPermissionChecker permissions, IStoreOfferingManagementRepository offerings)
    {
        public async Task<ManagedOfferingPage> ListAsync(Guid corporateId, Guid storeId, int page, int pageSize, CancellationToken token)
        {
            if (page < 1 || pageSize is < 1 or > 100) throw new ArgumentException("Geçersiz sayfalama.");
            await RequireAsync(corporateId, storeId, token);
            return await offerings.ListAsync(corporateId, storeId, page, pageSize, token);
        }

        public Task<Guid> SaveAsync(Guid corporateId, Guid storeId, Guid combinationId, bool isActive, decimal? priceOverride, CancellationToken token)
            => WriteAsync(corporateId, storeId, combinationId, "SAVE", isActive, priceOverride, token);

        public Task<Guid> SetActiveAsync(Guid corporateId, Guid storeId, Guid combinationId, bool isActive, CancellationToken token)
            => WriteAsync(corporateId, storeId, combinationId, "SET_ACTIVE", isActive, null, token);

        public Task<Guid> SetPriceAsync(Guid corporateId, Guid storeId, Guid combinationId, decimal? priceOverride, CancellationToken token)
            => WriteAsync(corporateId, storeId, combinationId, "SET_PRICE", null, priceOverride, token);

        private async Task<Guid> WriteAsync(Guid corporateId, Guid storeId, Guid combinationId, string operation, bool? isActive, decimal? priceOverride, CancellationToken token)
        {
            ValidateId(combinationId);
            if (priceOverride is decimal price && (price < 0 || price > 9999999999.99m || decimal.Round(price, 2) != price))
                throw new ArgumentException("Fiyat 0–9999999999,99 aralığında ve en çok iki ondalık basamaklı olmalıdır.");
            await RequireAsync(corporateId, storeId, token);
            return await offerings.WriteAsync(corporateId, storeId, combinationId, operation, isActive, priceOverride, token);
        }

        private async Task RequireAsync(Guid corporateId, Guid storeId, CancellationToken token)
        {
            ValidateId(corporateId); ValidateId(storeId);
            if (!user.IsAuthenticated || user.UserId is not Guid userId
                || !await permissions.HasPermissionAsync(userId, PermissionCodes.StoreOfferingManage, corporateId, storeId, token))
                throw new UnauthorizedAccessException();
        }

        private static void ValidateId(Guid id)
        {
            if (id == Guid.Empty) throw new ArgumentException("Kimlik boş olamaz.");
        }
    }
}

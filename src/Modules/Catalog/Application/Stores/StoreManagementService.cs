using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Domain;

namespace GiysiGo.Modules.Catalog.Application.Stores
{
    public sealed class StoreManagementService(ICurrentUser currentUser, IPermissionChecker permissions, IStoreManagementRepository stores)
    {
        public async Task<StorePage> GetPageAsync(Guid corporateId, bool includeInactive, int page, int pageSize, CancellationToken token)
        {
            ValidateId(corporateId);
            if (page < 1 || pageSize is < 1 or > 100) throw new ArgumentException("Sayfa en az 1; sayfa boyutu 1 ile 100 arasında olmalıdır.");
            await RequireAsync(PermissionCodes.StoreView, corporateId, token);
            return await stores.GetPageAsync(corporateId, includeInactive, page, pageSize, token);
        }

        public async Task<Store> GetAsync(Guid corporateId, Guid id, CancellationToken token)
        {
            ValidateId(corporateId); ValidateId(id);
            if (!currentUser.IsAuthenticated) throw new UnauthorizedAccessException();
            var userId = currentUser.UserId ?? throw new UnauthorizedAccessException();
            // Şirket yöneticisi pasif dükkânı da görebilir; personel yalnız aktif atandığı dükkânı görür.
            if (!await permissions.HasPermissionAsync(userId, PermissionCodes.StoreView, corporateId, cancellationToken: token)
                && !await permissions.HasPermissionAsync(userId, PermissionCodes.StoreView, corporateId, id, token))
                throw new UnauthorizedAccessException();
            return await stores.GetAsync(corporateId, id, token) ?? throw new KeyNotFoundException("Dükkân bu şirket kapsamında bulunamadı.");
        }

        public async Task<Guid> CreateAsync(Guid corporateId, StoreWriteData data, CancellationToken token)
        {
            ValidateId(corporateId); Validate(data);
            await RequireAsync(PermissionCodes.StoreManage, corporateId, token);
            return await stores.SaveAsync(corporateId, Guid.NewGuid(), Normalize(data), true, token);
        }

        public async Task UpdateAsync(Guid corporateId, Guid id, StoreWriteData data, CancellationToken token)
        {
            ValidateId(corporateId); ValidateId(id); Validate(data);
            await RequireAsync(PermissionCodes.StoreManage, corporateId, token);
            await stores.SaveAsync(corporateId, id, Normalize(data), false, token);
        }

        public async Task SetActiveAsync(Guid corporateId, Guid id, bool isActive, CancellationToken token)
        {
            ValidateId(corporateId); ValidateId(id);
            // Aktiflik şirket kapsamından denetlenir; pasif dükkânın yeniden açılması engellenmez.
            await RequireAsync(PermissionCodes.StoreManage, corporateId, token);
            await stores.SetActiveAsync(corporateId, id, isActive, token);
        }

        private async Task RequireAsync(string permission, Guid corporateId, CancellationToken token)
        {
            if (!currentUser.IsAuthenticated || currentUser.UserId is not Guid userId
                || !await permissions.HasPermissionAsync(userId, permission, corporateId, cancellationToken: token))
                throw new UnauthorizedAccessException();
        }

        private static void ValidateId(Guid id)
        {
            if (id == Guid.Empty) throw new ArgumentException("Kimlik boş olamaz.");
        }

        private static StoreWriteData Normalize(StoreWriteData data) => data with { Name = data.Name.Trim(), AddressText = data.AddressText.Trim() };

        private static void Validate(StoreWriteData data)
        {
            if (string.IsNullOrWhiteSpace(data.Name) || data.Name.Length > 200
                || string.IsNullOrWhiteSpace(data.AddressText) || data.AddressText.Length > 2000)
                throw new ArgumentException("Dükkân adı 1–200, adres 1–2000 karakter olmalıdır.");
            if (data.Latitude is < -90 or > 90 || data.Longitude is < -180 or > 180
                || decimal.Round(data.Latitude, 6) != data.Latitude || decimal.Round(data.Longitude, 6) != data.Longitude)
                throw new ArgumentException("Koordinatlar derece cinsinden, en fazla altı ondalık basamakla geçerli enlem/boylam aralığında olmalıdır.");
            if (data.ServiceRadiusKm is <= 0 or > 99999.99m || decimal.Round(data.ServiceRadiusKm, 2) != data.ServiceRadiusKm)
                throw new ArgumentException("Hizmet yarıçapı kilometre cinsinden 0'dan büyük, en fazla 99999,99 ve iki ondalık basamaklı olmalıdır.");
        }
    }
}

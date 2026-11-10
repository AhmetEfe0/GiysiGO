using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class TestPermissionChecker : IPermissionChecker
    {
        private readonly HashSet<(Guid UserId, string Code, Guid? CorporateId, Guid? StoreId)> grants = [];
        public Guid? SeenUserId { get; private set; }
        public string? SeenPermission { get; private set; }
        public Guid? SeenCorporateId { get; private set; }
        public Guid? SeenStoreId { get; private set; }

        public void Grant(Guid userId, string code, Guid? corporateId, Guid? storeId)
            => grants.Add((userId, code, corporateId, storeId));

        public Task<bool> HasPermissionAsync(Guid userId, string permissionCode,
            Guid? corporateId = null, Guid? storeId = null, CancellationToken cancellationToken = default)
        {
            SeenUserId = userId;
            SeenPermission = permissionCode;
            SeenCorporateId = corporateId;
            SeenStoreId = storeId;
            return Task.FromResult(grants.Contains((userId, permissionCode, corporateId, storeId)));
        }
    }
}

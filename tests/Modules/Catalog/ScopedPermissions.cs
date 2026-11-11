using GiysiGo.BuildingBlocks.Application.Contracts;
namespace GiysiGo.Modules.Catalog.Tests
{
    internal sealed class ScopedPermissions(Guid corporate, Guid store) : IPermissionChecker
    {
        public (string, Guid?, Guid?) LastScope { get; private set; }
        public Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId = null, Guid? storeId = null, CancellationToken cancellationToken = default)
        {
            LastScope = (permissionCode, corporateId, storeId);
            return Task.FromResult(corporateId == corporate && storeId == store && permissionCode == PermissionCodes.StoreOfferingManage);
        }
    }
}

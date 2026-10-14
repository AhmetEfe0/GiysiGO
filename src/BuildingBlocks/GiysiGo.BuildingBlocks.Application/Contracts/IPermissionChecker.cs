namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface IPermissionChecker
    {
        Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId = null, Guid? storeId = null, CancellationToken cancellationToken = default);
    }
}

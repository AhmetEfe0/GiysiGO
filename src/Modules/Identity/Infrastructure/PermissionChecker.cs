using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class PermissionChecker(SqlConnectionFactory connectionFactory,
        IIdentityAuthorizationRepository authorizationRepository, IStoreScopeReader storeScopeReader) : IPermissionChecker
    {
        public async Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId = null, Guid? storeId = null, CancellationToken cancellationToken = default)
        {
            if (userId == Guid.Empty || string.IsNullOrWhiteSpace(permissionCode)
                || corporateId == Guid.Empty || storeId == Guid.Empty)
            {
                return false;
            }

            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

            if (storeId.HasValue)
            {
                var store = await storeScopeReader.GetScopeAsync(storeId.Value, connection, transaction, cancellationToken);
                if (store is null || store.StoreId != storeId.Value || !store.IsActive || store.CorporateId == Guid.Empty
                    || (corporateId.HasValue && corporateId.Value != store.CorporateId))
                {
                    return false;
                }

                corporateId = store.CorporateId;
            }

            var allowed = await authorizationRepository.HasPermissionAsync(userId, permissionCode,
                corporateId, storeId, connection, transaction, cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return allowed;
        }
    }
}

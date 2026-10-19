using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Infrastructure;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class PermissionChecker(SqlConnectionFactory connectionFactory, IStoreScopeReader? storeScopeReader = null) : IPermissionChecker
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
                if (storeScopeReader is null)
                {
                    return false;
                }

                var store = await storeScopeReader.GetScopeAsync(storeId.Value, connection, transaction, cancellationToken);
                if (store is null || store.StoreId != storeId.Value || !store.IsActive || store.CorporateId == Guid.Empty
                    || (corporateId.HasValue && corporateId.Value != store.CorporateId))
                {
                    return false;
                }

                corporateId = store.CorporateId;
            }

            var command = new CommandDefinition("[identity].[spHasPermission]",
                new { UserId = userId, PermissionCode = permissionCode, CorporateId = corporateId, StoreId = storeId },
                transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken);
            var allowed = await connection.QuerySingleAsync<bool>(command);
            await transaction.CommitAsync(cancellationToken);
            return allowed;
        }
    }
}

using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class PermissionChecker(ITransactionRunner transactions, IStoreScopeReader stores) : IPermissionChecker
    {
        public Task<bool> HasPermissionAsync(Guid userId, string permissionCode, Guid? corporateId = null, Guid? storeId = null, CancellationToken cancellationToken = default)
        {
            if (userId == Guid.Empty || corporateId == Guid.Empty || storeId == Guid.Empty
                || string.IsNullOrWhiteSpace(permissionCode) || permissionCode.Length > 100)
                return Task.FromResult(false);

            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                var effectiveCorporateId = corporateId;
                if (storeId is Guid scopedStoreId)
                {
                    var scope = await stores.GetScopeAsync(scopedStoreId, connection, transaction, token);
                    if (scope is null || !scope.IsActive || (corporateId.HasValue && corporateId != scope.CorporateId))
                        return false;
                    effectiveCorporateId = scope.CorporateId;
                }

                return await connection.QuerySingleAsync<bool>(new CommandDefinition(
                    "identity.spHasPermission",
                    new { UserId = userId, PermissionCode = permissionCode, CorporateId = effectiveCorporateId, StoreId = storeId },
                    transaction, commandType: CommandType.StoredProcedure, cancellationToken: token));
            }, cancellationToken);
        }
    }
}

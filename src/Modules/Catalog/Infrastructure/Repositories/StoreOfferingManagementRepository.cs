using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Catalog.Application.Offerings;
using GiysiGo.Modules.Catalog.Application.Repositories;

namespace GiysiGo.Modules.Catalog.Infrastructure.Repositories
{
    public sealed class StoreOfferingManagementRepository(ITransactionRunner transactions, ICorporateStatusReader corporates,
        ICurrentUser user, ITransactionalPermissionChecker permissions) : IStoreOfferingManagementRepository
    {
        public Task<ManagedOfferingPage> ListAsync(Guid corporateId, Guid storeId, int page, int pageSize, CancellationToken token)
            => transactions.ExecuteAsync<ManagedOfferingPage>(async (connection, transaction, cancellationToken) =>
            {
                if (!await corporates.IsActiveAsync(corporateId, connection, transaction, cancellationToken))
                    throw new KeyNotFoundException("Aktif şirket bulunamadı.");
                using var results = await connection.QueryMultipleAsync(new CommandDefinition("catalog.usp_GetManagedOfferings",
                    new { CorporateId = corporateId, StoreId = storeId, Page = page, PageSize = pageSize }, transaction,
                    commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
                return new ManagedOfferingPage((await results.ReadAsync<ManagedOffering>()).AsList(), page, pageSize, await results.ReadSingleAsync<long>());
            }, token);

        public Task<Guid> WriteAsync(Guid corporateId, Guid storeId, Guid combinationId, string operation, bool? isActive, decimal? priceOverride, CancellationToken token)
            => transactions.ExecuteAsync(async (connection, transaction, cancellationToken) =>
            {
                await connection.ExecuteAsync(new CommandDefinition("catalog.usp_LockStoreOfferingWrite",
                    new { CorporateId = corporateId, StoreId = storeId }, transaction,
                    commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
                if (!user.IsAuthenticated || user.UserId is not Guid userId
                    || !await permissions.HasPermissionAsync(userId, PermissionCodes.StoreOfferingManage, corporateId, storeId,
                        connection, transaction, cancellationToken))
                    throw new UnauthorizedAccessException();
                if (!await corporates.IsActiveAsync(corporateId, connection, transaction, cancellationToken))
                    throw new KeyNotFoundException("Aktif şirket bulunamadı.");
                return await connection.QuerySingleAsync<Guid>(new CommandDefinition("catalog.usp_ManageStoreOffering",
                    new { CorporateId = corporateId, StoreId = storeId, CombinationId = combinationId, Operation = operation, IsActive = isActive, PriceOverride = priceOverride },
                    transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
            }, IsolationLevel.Serializable, token);
    }
}

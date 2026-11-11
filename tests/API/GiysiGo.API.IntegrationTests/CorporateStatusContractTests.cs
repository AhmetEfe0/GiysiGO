using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Application.Stores;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class CorporateStatusContractTests
    {
        [StoreSqlFact]
        public async Task Active_corporate_decision_is_held_until_the_callers_transaction_ends()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            await using var connection = await db.Connections.OpenAsync();
            await using var transaction = await connection.BeginTransactionAsync();
            Assert.True(await db.Get<ICorporateStatusReader>().IsActiveAsync(corporate, connection, transaction));
            var mutation = await File.ReadAllTextAsync(System.IO.Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetCorporateLifecycle.sql"));
            var parameters = new { Id = corporate, IsActive = false, DeleteDate = (DateTime?)null };
            await using var other = await db.Connections.OpenAsync();
            var blocked = await Assert.ThrowsAsync<SqlException>(() => other.ExecuteAsync(mutation, parameters, commandTimeout: 1));
            Assert.Equal(-2, blocked.Number);
            await transaction.RollbackAsync();
            await other.ExecuteAsync(mutation, parameters);
            await using var after = await other.BeginTransactionAsync();
            Assert.False(await db.Get<ICorporateStatusReader>().IsActiveAsync(corporate, other, after));
        }

        [StoreSqlFact]
        public async Task Scope_keeps_corporate_identity_while_identity_contract_hides_inactive_parent()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate); db.ActAs(owner);
            var id = await db.CreateAsync(corporate);
            var status = db.Get<ICorporateStatusReader>();
            var scopes = db.Get<IStoreScopeReader>();
            var catalog = db.Get<ITransactionalStoreCatalogReader>();
            var mutation = await File.ReadAllTextAsync(System.IO.Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetCorporateLifecycle.sql"));
            await using var connection = await db.Connections.OpenAsync();
            foreach (var state in new[] { (Active: false, Deleted: (DateTime?)null), (Active: true, Deleted: (DateTime?)DateTime.UtcNow) })
            {
                await using var transaction = await connection.BeginTransactionAsync();
                Assert.True(await status.IsActiveAsync(corporate, connection, transaction));
                await connection.ExecuteAsync(mutation, new { Id = corporate, IsActive = state.Active, DeleteDate = state.Deleted }, transaction);
                var scope = await scopes.GetScopeAsync(id, connection, transaction);
                Assert.NotNull(scope); Assert.Equal(corporate, scope.CorporateId); Assert.True(scope.IsActive);
                Assert.False(await status.IsActiveAsync(corporate, connection, transaction));
                Assert.False(await db.Get<IIdentityAuthorizationRepository>().HasPermissionAsync(owner, PermissionCodes.StoreView, corporate, id, connection, transaction));
                Assert.Null(await catalog.GetStoreLocationAsync(id, connection, transaction));
                Assert.False(await catalog.ServesLocationAsync(id, 41, 29, connection, transaction));
                Assert.Null(await catalog.GetOfferingAsync(id, Guid.NewGuid(), Guid.NewGuid(), connection, transaction));
                await transaction.RollbackAsync();
            }
            Assert.NotNull(await db.Get<IStoreCatalogReader>().GetStoreLocationAsync(id));
            await using var borrowed = await connection.BeginTransactionAsync();
            Assert.False(await status.IsActiveAsync(Guid.NewGuid(), connection, borrowed));
            await Assert.ThrowsAsync<ArgumentException>(() => status.IsActiveAsync(Guid.Empty, connection, borrowed));
            await using var other = await db.Connections.OpenAsync();
            await Assert.ThrowsAsync<ArgumentException>(() => status.IsActiveAsync(corporate, other, borrowed));
            using var cancelled = new CancellationTokenSource(); cancelled.Cancel();
            await Assert.ThrowsAnyAsync<OperationCanceledException>(() => status.IsActiveAsync(corporate, connection, borrowed, cancelled.Token));
        }

        [StoreSqlFact]
        public async Task Management_repository_uses_identity_status_before_reading_or_writing()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var id = await db.CreateAsync(corporate);
            var stores = db.Get<IStoreManagementRepository>();
            await db.ExecuteAsync("SetCorporateLifecycle.sql", new { Id = corporate, IsActive = false, DeleteDate = (DateTime?)null });
            Assert.Null(await stores.GetAsync(corporate, id, CancellationToken.None));
            Assert.Empty((await stores.GetPageAsync(corporate, true, 1, 20, CancellationToken.None)).Items);
            await Assert.ThrowsAsync<KeyNotFoundException>(() => stores.SaveAsync(corporate, Guid.NewGuid(), new StoreWriteData("Ad", "Adres", 41, 29, 5), true, CancellationToken.None));
            await Assert.ThrowsAsync<KeyNotFoundException>(() => stores.SetActiveAsync(corporate, id, false, CancellationToken.None));
            await db.ExecuteAsync("SetCorporateLifecycle.sql", new { Id = corporate, IsActive = true, DeleteDate = (DateTime?)null });
            Assert.True((await stores.GetAsync(corporate, id, CancellationToken.None))!.IsActive);
        }
    }
}

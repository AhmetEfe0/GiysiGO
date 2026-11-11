using System.Data;
using System.Data.Common;
using System.Net;
using System.Net.Http.Json;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Infrastructure;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class StoreOfferingAuthorizationRaceTests
    {
        [StoreSqlFact]
        public Task Revoked_assignment_between_service_check_and_write_is_rejected() => VerifyAsync(true, false);

        [StoreSqlFact]
        public Task Revoked_permission_between_service_check_and_write_is_rejected() => VerifyAsync(true, true);

        [StoreSqlFact]
        public Task Assignment_remains_locked_until_offering_write_commits() => VerifyAsync(false, false);

        [StoreSqlFact]
        public Task Permission_remains_locked_until_offering_write_commits() => VerifyAsync(false, true);

        private static async Task VerifyAsync(bool beforeCheck, bool permission)
        {
            var paused = new TaskCompletionSource<DbTransaction>(TaskCreationOptions.RunContinuationsAsynchronously);
            var resume = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
            await using var db = new StoreTestDatabase(services => services.AddScoped<ITransactionalPermissionChecker>(provider =>
                new PausingOfferingPermissionChecker(ActivatorUtilities.CreateInstance<PermissionChecker>(provider), beforeCheck, paused, resume.Task)));
            var corporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate);
            db.ActAs(owner);
            var store = await db.CreateAsync(corporate);
            var role = Guid.NewGuid(); var code = "OfferingRace_" + role.ToString("N");
            var category = Guid.NewGuid(); var product = Guid.NewGuid(); var service = Guid.NewGuid();
            var pair = Guid.NewGuid(); var offering = Guid.NewGuid();
            object Fixture(string operation) => new { Operation = operation, Hidden = (string?)null, PriceOverride = (decimal?)null,
                CategoryId = category, ProductId = product, ServiceId = service, PairId = pair, OfferingId = offering, StoreId = store };
            try
            {
                await db.ExecuteAsync("OfferingRaceRole.sql", new { Operation = "CREATE", RoleId = role, Code = code });
                var actor = await db.UserAsync(code, storeId: store);
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Fixture("CREATE"));
                db.ActAs(actor);
                var path = StoreTestDatabase.Path(corporate, store) + "/offerings/" + pair + "/price";
                var request = db.Client.PatchAsJsonAsync(path, new { priceOverride = 42m });
                try
                {
                    var transaction = await paused.Task.WaitAsync(TimeSpan.FromSeconds(10));
                    Assert.Equal(IsolationLevel.Serializable, transaction.IsolationLevel);
                    if (beforeCheck) await RevokeAsync(false);
                    else
                    {
                        var blocked = await Assert.ThrowsAsync<SqlException>(() => RevokeAsync(true));
                        Assert.Equal(1222, blocked.Number);
                    }
                }
                finally { resume.TrySetResult(); }
                using var response = await request.WaitAsync(TimeSpan.FromSeconds(10));
                Assert.Equal(beforeCheck ? HttpStatusCode.Forbidden : HttpStatusCode.NoContent, response.StatusCode);
                Assert.Equal(beforeCheck ? 125.25m : 42m, (await db.Get<IStoreCatalogReader>().GetOfferingAsync(store, product, service))?.UnitPrice);
                if (!beforeCheck) await RevokeAsync(false);
                using var denied = await db.Client.PatchAsJsonAsync(path, new { priceOverride = 99m });
                Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);

                async Task RevokeAsync(bool shortTimeout)
                {
                    await using var connection = await db.Connections.OpenAsync();
                    if (shortTimeout) await connection.ExecuteAsync(await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetStaffLockTimeout.sql")));
                    await using var transaction = await connection.BeginTransactionAsync();
                    var access = db.Get<IIdentityAccessRepository>();
                    if (permission)
                    {
                        var grants = await access.GetRolePermissionListAsync(role, connection, transaction);
                        await access.RevokeRolePermissionAsync(role, Assert.Single(grants).PermissionId, connection, transaction);
                    }
                    else await access.RevokeStoreAssignmentAsync(actor, store, role, connection, transaction);
                    await transaction.CommitAsync();
                }
            }
            finally
            {
                resume.TrySetResult();
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Fixture("DELETE"));
                await db.ExecuteAsync("OfferingRaceRole.sql", new { Operation = "DELETE", RoleId = role, Code = code });
            }
        }
    }
}

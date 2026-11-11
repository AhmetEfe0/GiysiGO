using System.Data;
using System.Net;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces.Authorization;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class StaffAssignmentConcurrencyTests
    {
        [StoreSqlFact]
        public Task Manager_role_cannot_be_revoked_between_authorization_and_assignment()
            => VerifyConcurrentChangeAsync("manager");

        [StoreSqlFact]
        public Task Owner_membership_cannot_be_revoked_between_authorization_and_assignment()
            => VerifyConcurrentChangeAsync("owner");

        [StoreSqlFact]
        public Task Corporate_cannot_be_disabled_between_authorization_and_assignment()
            => VerifyConcurrentChangeAsync("corporate");

        [StoreSqlFact]
        public Task Store_cannot_be_disabled_between_authorization_and_assignment()
            => VerifyConcurrentChangeAsync("store");

        private static async Task VerifyConcurrentChangeAsync(string change)
        {
            var authorized = new TaskCompletionSource<(IsolationLevel Isolation, int Session)>(TaskCreationOptions.RunContinuationsAsynchronously);
            var resume = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
            await using var db = new StoreTestDatabase(services => services.AddScoped<IStaffAssignmentAuthorizer>(provider =>
                new PausingStaffAssignmentAuthorizer(provider.GetRequiredService<IIdentityAuthorizationRepository>(),
                    provider.GetRequiredService<IStoreScopeReader>(), authorized, resume.Task)));
            var corporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate);
            db.ActAs(owner);
            var store = await db.CreateAsync(corporate);
            var manager = await db.UserAsync("StoreManager", storeId: store);
            var employee = await db.UserAsync("Customer");
            var roles = await db.Get<IRoleRepository>().GetAllAsync();
            var staffRole = roles.Single(role => role.Code == "StoreStaff").Id;
            var managerRole = roles.Single(role => role.Code == "StoreManager").Id;
            var ownerRole = roles.Single(role => role.Code == "CorporateOwner").Id;
            db.ActAs(change == "owner" ? owner : manager);
            var path = $"/corporates/{corporate}/stores/{store}/staff/{employee}/roles/{staffRole}";
            var request = db.Client.PutAsync(path, null);
            try
            {
                var snapshot = await authorized.Task.WaitAsync(TimeSpan.FromSeconds(10));
                Assert.Equal(IsolationLevel.Serializable, snapshot.Isolation);
                var blocked = await Assert.ThrowsAsync<SqlException>(() => ChangeAsync(snapshot.Session, true));
                Assert.Equal(1222, blocked.Number);
            }
            finally
            {
                resume.TrySetResult();
                using var response = await request.WaitAsync(TimeSpan.FromSeconds(10));
                Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
            }

            var members = await db.Get<ITransactionRunner>().ExecuteAsync((connection, transaction, token) =>
                db.Get<IStaffManagementRepository>().GetMembersAsync(corporate, store, 1, 100, connection, transaction, token));
            Assert.Single(members.Items, item => item.UserId == employee && item.RoleId == staffRole);
            await ChangeAsync(null, false);
            using var denied = await db.Client.PutAsync(path, null);
            Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);

            async Task ChangeAsync(int? protectedSession, bool shortTimeout)
            {
                await using var connection = await db.Connections.OpenAsync();
                if (protectedSession.HasValue) Assert.NotEqual(protectedSession.Value, ((SqlConnection)connection).ServerProcessId);
                if (shortTimeout)
                    await connection.ExecuteAsync(await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetStaffLockTimeout.sql")));
                await using var transaction = await connection.BeginTransactionAsync();
                switch (change)
                {
                    case "manager":
                        await db.Get<IIdentityAccessRepository>().RevokeStoreAssignmentAsync(manager, store, managerRole, connection, transaction);
                        break;
                    case "owner":
                        await db.Get<IIdentityAccessRepository>().RevokeCorporateMembershipAsync(owner, corporate, ownerRole, connection, transaction);
                        break;
                    case "corporate":
                        await db.Get<IStaffManagementRepository>().SetCorporateActiveAsync(corporate, false, connection, transaction, default);
                        break;
                    case "store":
                        await connection.ExecuteAsync(await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetStoreLifecycle.sql")),
                            new { Id = store, IsActive = false, DeleteDate = (DateTime?)null }, transaction);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(nameof(change));
                }
                await transaction.CommitAsync();
            }
        }
    }
}

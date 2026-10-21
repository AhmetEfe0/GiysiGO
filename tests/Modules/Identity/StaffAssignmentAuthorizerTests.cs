using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Infrastructure;

namespace GiysiGo.Modules.Identity.Tests
{
    public sealed class StaffAssignmentAuthorizerTests
    {
        [SqlServerFact]
        public async Task Staff_assignment_respects_scope_and_role_hierarchy()
        {
            using var db = new IdentityDatabase();
            var roles = (await db.Get<IRoleRepository>().GetAllAsync()).ToDictionary(role => role.Code);
            var corporate = await db.Get<ICorporateRepository>().InsertAsync(new() { Name = "Assignment test" });
            var otherCorporate = await db.Get<ICorporateRepository>().InsertAsync(new() { Name = "Other assignment test" });
            var store = await db.CreateStoreAsync(corporate);
            var admin = await db.CreateUserAsync();
            var owner = await db.CreateUserAsync();
            var manager = await db.CreateUserAsync();
            var target = await db.CreateUserAsync();
            var authorizationRepository = db.Get<IIdentityAuthorizationRepository>();
            var authorizer = new StaffAssignmentAuthorizer(authorizationRepository,
                new FixtureStoreScopeReader(store, corporate));
            var access = db.Get<IIdentityAccessRepository>();

            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                await access.GrantUserRoleAsync(admin, roles["PlatformAdmin"].Id, connection, transaction, token);
                await access.GrantCorporateMembershipAsync(owner, corporate, roles["CorporateOwner"].Id, connection, transaction, token);
                await access.GrantStoreAssignmentAsync(manager, store, roles["StoreManager"].Id, connection, transaction, token);

                async Task<bool> Can(Guid actor, Guid subject, string role, Guid? corporateId, Guid? storeId) =>
                    await authorizer.CanManageAsync(actor, subject, roles[role].Id, corporateId, storeId, connection, transaction, token);

                Assert.True(await Can(admin, target, "CorporateOwner", corporate, null));
                Assert.True(await Can(admin, target, "StoreManager", corporate, store));
                Assert.True(await Can(owner, target, "StoreManager", corporate, store));
                Assert.True(await Can(owner, target, "StoreStaff", null, store));
                Assert.False(await Can(owner, target, "StoreStaff", otherCorporate, store));
                Assert.False(await Can(owner, target, "CorporateOwner", corporate, null));
                Assert.True(await Can(manager, target, "StoreStaff", corporate, store));
                Assert.False(await Can(manager, target, "StoreManager", corporate, store));
                Assert.False(await Can(manager, target, "CorporateOwner", corporate, null));
                Assert.False(await Can(manager, manager, "StoreStaff", corporate, store));
                Assert.False(await Can(manager, target, "StoreStaff", otherCorporate, store));
                Assert.False(await Can(manager, target, "StoreStaff", corporate, Guid.NewGuid()));
                Assert.False(await Can(target, owner, "StoreStaff", corporate, store));
                await Assert.ThrowsAsync<InvalidOperationException>(() =>
                    new StaffAssignmentAuthorizer(authorizationRepository)
                        .CanManageAsync(owner, target, roles["StoreStaff"].Id,
                        corporate, store, connection, transaction, token));

                await db.Get<IUserRepository>().SetActiveAsync(manager, false, connection, transaction, token);
                Assert.False(await Can(manager, target, "StoreStaff", corporate, store));
                await db.Get<IUserRepository>().SetActiveAsync(target, false, connection, transaction, token);
                Assert.False(await Can(admin, target, "StoreManager", corporate, store));
                return true;
            });
        }
    }
}

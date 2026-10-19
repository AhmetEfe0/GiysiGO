using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;
using GiysiGo.Modules.Identity.Infrastructure;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace GiysiGo.Modules.Identity.Tests
{
    public sealed class IdentityPermissionTests
    {
        [Fact]
        public void Current_user_reads_only_a_valid_authenticated_identifier()
        {
            var context = new DefaultHttpContext();
            var current = new CurrentUser(new HttpContextAccessor { HttpContext = context });
            Assert.False(current.IsAuthenticated);
            Assert.Null(current.UserId);

            context.User = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString()) }, "test"));
            Assert.True(current.IsAuthenticated);
            Assert.NotNull(current.UserId);

            context.User = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim(ClaimTypes.NameIdentifier, "invalid") }, "test"));
            Assert.False(current.IsAuthenticated);
            Assert.Null(current.UserId);
        }

        [SqlServerFact]
        public async Task Seed_is_idempotent_and_permissions_require_the_correct_scope()
        {
            using var db = new IdentityDatabase();
            var roles = (await db.Get<IRoleRepository>().GetAllAsync()).ToDictionary(role => role.Code);
            var permissions = (await db.Get<IPermissionRepository>().GetAllAsync()).ToDictionary(permission => permission.Code);
            Assert.Equal(5, roles.Count(role => new[] { "Customer", "PlatformAdmin", "CorporateOwner", "StoreManager", "StoreStaff" }.Contains(role.Key)));
            Assert.Equal(9, permissions.Count(permission => new[] { PermissionCodes.StoreView, PermissionCodes.StoreStaffManage, PermissionCodes.StoreOfferingManage, PermissionCodes.OrderView, PermissionCodes.OrderInspect, PermissionCodes.QuotePrepare, PermissionCodes.QuoteApprove, PermissionCodes.OrderProcess, PermissionCodes.OrderFulfill }.Contains(permission.Key)));
            Assert.Equal("GLOBAL", roles["Customer"].Scope);
            Assert.Equal("CORPORATE", roles["CorporateOwner"].Scope);
            Assert.Equal("STORE", roles["StoreStaff"].Scope);
            Assert.False(permissions[PermissionCodes.OrderFulfill].IsActive);
            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                var staffGrants = await db.Get<IIdentityAccessRepository>().GetRolePermissionListAsync(roles["StoreStaff"].Id, connection, transaction, token);
                Assert.Equal(5, staffGrants.Count);
                Assert.Contains(staffGrants, grant => grant.PermissionId == permissions[PermissionCodes.QuotePrepare].Id);
                Assert.DoesNotContain(staffGrants, grant => grant.PermissionId == permissions[PermissionCodes.QuoteApprove].Id);
                var managerGrants = await db.Get<IIdentityAccessRepository>().GetRolePermissionListAsync(roles["StoreManager"].Id, connection, transaction, token);
                Assert.DoesNotContain(managerGrants, grant => grant.PermissionId == permissions[PermissionCodes.QuoteApprove].Id);
                return true;
            });

            var user = await db.CreateUserAsync();
            var otherCorporate = await db.Get<ICorporateRepository>().InsertAsync(new Corporate { Name = "Other corporate" });
            var corporate = await db.Get<ICorporateRepository>().InsertAsync(new Corporate { Name = "Permission test" });
            var store = await db.CreateStoreAsync(corporate);
            var checker = new PermissionChecker(db.Factory, new FixtureStoreScopeReader(store, corporate));
            Assert.NotNull(db.Get<IPermissionChecker>());
            var access = db.Get<IIdentityAccessRepository>();

            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                await access.GrantUserRoleAsync(user, roles["Customer"].Id, connection, transaction, token);
                await access.GrantCorporateMembershipAsync(user, corporate, roles["CorporateOwner"].Id, connection, transaction, token);
                return true;
            });

            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.QuotePrepare));
            Assert.True(await checker.HasPermissionAsync(user, PermissionCodes.QuotePrepare, corporate));
            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.OrderFulfill, corporate));
            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.QuotePrepare, otherCorporate));
            Assert.True(await checker.HasPermissionAsync(user, PermissionCodes.QuoteApprove, storeId: store));
            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.QuoteApprove, otherCorporate, store));
            Assert.False(await checker.HasPermissionAsync(user, "unknown.permission", corporate));
            await Assert.ThrowsAsync<InvalidOperationException>(() => new PermissionChecker(db.Factory).HasPermissionAsync(user, PermissionCodes.QuoteApprove, storeId: store));

            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                await access.RevokeCorporateMembershipAsync(user, corporate, roles["CorporateOwner"].Id, connection, transaction, token);
                await access.GrantStoreAssignmentAsync(user, store, roles["StoreStaff"].Id, connection, transaction, token);
                return true;
            });
            Assert.True(await checker.HasPermissionAsync(user, PermissionCodes.QuotePrepare, storeId: store));
            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.QuoteApprove, storeId: store));
            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.QuotePrepare, corporate));
            Assert.False(await new PermissionChecker(db.Factory, new FixtureStoreScopeReader(store, corporate, false)).HasPermissionAsync(user, PermissionCodes.QuotePrepare, storeId: store));

            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                await db.Get<IUserRepository>().SetActiveAsync(user, false, connection, transaction, token);
                return true;
            });
            Assert.False(await checker.HasPermissionAsync(user, PermissionCodes.QuotePrepare, storeId: store));
        }
    }
}

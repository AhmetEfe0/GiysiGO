using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Application.Models;
using GiysiGo.BuildingBlocks.Application.Transactions;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class StaffManagementHttpTests
    {
        [StoreSqlFact]
        public async Task Platform_creates_company_assigns_owner_and_controls_activation()
        {
            await using var db = new StoreTestDatabase();
            var admin = await db.UserAsync("PlatformAdmin");
            var customer = await db.UserAsync("Customer");
            var role = await Role(db, "CorporateOwner");
            await Status(db.Client.PostAsJsonAsync("/corporates", new { name = "Company" }), HttpStatusCode.Unauthorized);
            db.ActAs(customer);
            var customerAccess = await db.Get<ITransactionRunner>().ExecuteAsync((connection, transaction, token) =>
                db.Get<IStaffManagementRepository>().GetAccessAsync(customer, connection, transaction, token));
            Assert.Contains(customerAccess, item => item.RoleCode == "Customer");
            await Status(db.Client.PostAsJsonAsync("/corporates", new { name = "Company" }), HttpStatusCode.Forbidden);
            db.ActAs(admin);
            using var response = await db.Client.PostAsJsonAsync("/corporates", new { name = "Company" });
            Assert.Equal(HttpStatusCode.Created, response.StatusCode);
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            var corporate = body.RootElement.GetProperty("id").GetGuid();
            try
            {
                var path = Member(corporate, customer, role);
                await Status(db.Client.PutAsync(path, null), HttpStatusCode.NoContent);
                await Status(db.Client.PutAsync(path, null), HttpStatusCode.NoContent);
                var members = await db.Client.GetFromJsonAsync<StaffMemberPage>($"/corporates/{corporate}/members");
                Assert.NotNull(members); Assert.Equal(1, members.TotalCount);
                db.ActAs(customer);
                await Status(db.Client.PatchAsJsonAsync($"/corporates/{corporate}/active", new { isActive = false }), HttpStatusCode.Forbidden);
                db.ActAs(admin);
                await Status(db.Client.PatchAsJsonAsync($"/corporates/{corporate}/active", new { isActive = false }), HttpStatusCode.NoContent);
                db.ActAs(customer);
                var hidden = await db.Client.GetFromJsonAsync<StaffScopeAccess[]>("/me/access");
                Assert.DoesNotContain(hidden!, item => item.CorporateId == corporate);
                db.ActAs(admin);
                await Status(db.Client.PatchAsJsonAsync($"/corporates/{corporate}/active", new { isActive = true }), HttpStatusCode.NoContent);
                await Status(db.Client.DeleteAsync(path), HttpStatusCode.NoContent);
                await Status(db.Client.DeleteAsync(path), HttpStatusCode.NoContent);
                await Status(db.Client.PutAsync(path, null), HttpStatusCode.NoContent);
                var restored = await db.Client.GetFromJsonAsync<StaffMemberPage>($"/corporates/{corporate}/members");
                Assert.Equal(1, restored!.TotalCount);
                await Status(db.Client.PostAsJsonAsync("/corporates", new { name = "Company", ownerId = customer }), HttpStatusCode.BadRequest);
                await Status(db.Client.PatchAsJsonAsync($"/corporates/{corporate}/active", new { }), HttpStatusCode.BadRequest);
            }
            finally
            {
                await db.ExecuteAsync("CleanupStoreManagementFixture.sql", new { CorporateIds = new[] { corporate }, UserIds = Array.Empty<Guid>() });
            }
        }

        [StoreSqlFact]
        public async Task Owner_and_manager_follow_role_hierarchy_and_store_scope()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            var otherCorporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate);
            var otherOwner = await db.UserAsync("CorporateOwner", otherCorporate);
            db.ActAs(owner); var store = await db.CreateAsync(corporate);
            db.ActAs(otherOwner); var otherStore = await db.CreateAsync(otherCorporate);
            var target = await db.UserAsync("Customer");
            var managerRole = await Role(db, "StoreManager");
            var staffRole = await Role(db, "StoreStaff");
            var ownerRole = await Role(db, "CorporateOwner");
            var adminRole = await Role(db, "PlatformAdmin");
            db.ActAs(owner);
            await Status(db.Client.PutAsync(Staff(corporate, store, target, managerRole), null), HttpStatusCode.NoContent);
            await Status(db.Client.PutAsync(Member(corporate, target, ownerRole), null), HttpStatusCode.Forbidden);
            await Status(db.Client.PutAsync(Staff(otherCorporate, otherStore, target, staffRole), null), HttpStatusCode.Forbidden);
            await Status(db.Client.PutAsync(Staff(corporate, otherStore, target, staffRole), null), HttpStatusCode.Forbidden);
            await Status(db.Client.PutAsync(Staff(corporate, store, owner, managerRole), null), HttpStatusCode.Forbidden);
            await Status(db.Client.PutAsync(Staff(corporate, store, target, adminRole), null), HttpStatusCode.Forbidden);
            var employee = await db.UserAsync("Customer");
            db.ActAs(target);
            await Status(db.Client.PutAsync(Staff(corporate, store, employee, managerRole), null), HttpStatusCode.Forbidden);
            var grants = await Task.WhenAll(db.Client.PutAsync(Staff(corporate, store, employee, staffRole), null),
                db.Client.PutAsync(Staff(corporate, store, employee, staffRole), null));
            foreach (var grant in grants) { Assert.Equal(HttpStatusCode.NoContent, grant.StatusCode); grant.Dispose(); }
            var members = await db.Client.GetFromJsonAsync<StaffMemberPage>($"/corporates/{corporate}/stores/{store}/staff?pageSize=1");
            Assert.Equal(2, members!.TotalCount); Assert.Single(members.Items);
            await Status(db.Client.GetAsync($"/corporates/{otherCorporate}/stores/{otherStore}/staff"), HttpStatusCode.Forbidden);
            db.ActAs(employee);
            await Status(db.Client.GetAsync($"/corporates/{corporate}/stores/{store}/staff"), HttpStatusCode.Forbidden);
            db.ActAs(target);
            await Status(db.Client.DeleteAsync(Staff(corporate, store, employee, staffRole)), HttpStatusCode.NoContent);
            await Status(db.Client.DeleteAsync(Staff(corporate, store, employee, staffRole)), HttpStatusCode.NoContent);
            db.ActAs(employee);
            var revoked = await db.Client.GetFromJsonAsync<StaffScopeAccess[]>("/me/access");
            Assert.DoesNotContain(revoked!, item => item.StoreId == store);
            db.ActAs(target);
            await Status(db.Client.PutAsync(Staff(corporate, store, employee, staffRole), null), HttpStatusCode.NoContent);
            db.ActAs(employee);
            Assert.Contains((await db.Client.GetFromJsonAsync<StaffScopeAccess[]>("/me/access"))!, item => item.StoreId == store);
        }

        [StoreSqlFact]
        public async Task My_access_reports_only_active_assignments_and_current_permissions()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            var otherCorporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate);
            var otherOwner = await db.UserAsync("CorporateOwner", otherCorporate);
            db.ActAs(owner); var store = await db.CreateAsync(corporate);
            db.ActAs(otherOwner); var otherStore = await db.CreateAsync(otherCorporate);
            var employee = await db.UserAsync("Customer");
            var staffRole = await Role(db, "StoreStaff");
            var managerRole = await Role(db, "StoreManager");
            db.ActAs(owner);
            await Status(db.Client.PutAsync(Staff(corporate, store, employee, staffRole), null), HttpStatusCode.NoContent);
            db.ActAs(otherOwner);
            await Status(db.Client.PutAsync(Staff(otherCorporate, otherStore, employee, managerRole), null), HttpStatusCode.NoContent);
            db.ActAs(employee);
            var contexts = (await db.Client.GetFromJsonAsync<StaffScopeAccess[]>("/me/access"))!;
            var staff = Assert.Single(contexts, item => item.StoreId == store);
            Assert.Equal(corporate, staff.CorporateId);
            Assert.Contains("StoreStaff", staff.Roles);
            Assert.Contains("quote.prepare", staff.Permissions);
            Assert.DoesNotContain("quote.approve", staff.Permissions);
            Assert.Contains(contexts, item => item.StoreId == otherStore && item.Roles.Contains("StoreManager"));
            await db.ExecuteAsync("SetStoreLifecycle.sql", new { Id = otherStore, IsActive = false, DeleteDate = (DateTime?)null });
            await db.ExecuteAsync("SetCorporateLifecycle.sql", new { Id = corporate, IsActive = false, DeleteDate = (DateTime?)null });
            var inactive = (await db.Client.GetFromJsonAsync<StaffScopeAccess[]>("/me/access"))!;
            Assert.DoesNotContain(inactive, item => item.Scope == "STORE");
            await Status(db.Client.GetAsync($"/corporates/{corporate}/members?pageSize=101"), HttpStatusCode.BadRequest);
        }

        private static async Task<Guid> Role(StoreTestDatabase db, string code)
            => (await db.Get<IRoleRepository>().GetAllAsync()).Single(role => role.Code == code).Id;

        private static string Member(Guid corporate, Guid user, Guid role)
            => $"/corporates/{corporate}/members/{user}/roles/{role}";

        private static string Staff(Guid corporate, Guid store, Guid user, Guid role)
            => $"/corporates/{corporate}/stores/{store}/staff/{user}/roles/{role}";

        private static async Task Status(Task<HttpResponseMessage> request, HttpStatusCode expected)
        {
            using var response = await request;
            Assert.True(response.StatusCode == expected,
                $"Expected {expected}, received {response.StatusCode}. {await response.Content.ReadAsStringAsync()}");
        }
    }
}

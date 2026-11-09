using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Dapper;
using GiysiGo.API.Controllers.Stores;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Authorization;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Application.Stores;
using GiysiGo.BuildingBlocks.Application.Transactions;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreManagementHttpTests
    {
        [StoreSqlFact]
        public async Task Owner_manages_multiple_stores_with_shared_pagination_and_no_corporate_leak()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var first = await db.CreateAsync(corporate, "A şube");
            var second = await db.CreateAsync(corporate, "B şube");
            using var response = await db.Client.GetAsync(StoreTestDatabase.Path(corporate));
            response.EnsureSuccessStatusCode();
            var page = await response.Content.ReadFromJsonAsync<StorePageDto>();
            Assert.NotNull(page); Assert.Equal(1, page.Page); Assert.Equal(20, page.PageSize); Assert.Equal(2, page.TotalCount);
            Assert.Equal(new[] { first, second }, page.Items.Select(store => store.Id));
            using var secondPage = await db.Client.GetAsync(StoreTestDatabase.Path(corporate) + "?page=2&pageSize=1");
            var next = await secondPage.Content.ReadFromJsonAsync<StorePageDto>();
            Assert.NotNull(next); Assert.Equal(second, Assert.Single(next.Items).Id); Assert.Equal(2, next.TotalCount);
            using var emptyPage = await db.Client.GetAsync(StoreTestDatabase.Path(corporate) + "?page=2147483647&pageSize=100");
            var empty = await emptyPage.Content.ReadFromJsonAsync<StorePageDto>();
            Assert.NotNull(empty); Assert.Empty(empty.Items); Assert.Equal(2, empty.TotalCount);
            var otherCorporate = await db.CorporateAsync();
            using var forbidden = await db.Client.GetAsync(StoreTestDatabase.Path(otherCorporate));
            await AssertProblem(forbidden, 403);
        }

        [StoreSqlFact]
        public async Task Updates_and_repeated_activation_preserve_corporate_and_allow_reopening()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var id = await db.CreateAsync(corporate);
            var path = StoreTestDatabase.Path(corporate, id);
            using var update = await db.Client.PutAsJsonAsync(path, StoreTestDatabase.ValidRequest("Yeni ad"));
            Assert.Equal(HttpStatusCode.NoContent, update.StatusCode);
            for (var i = 0; i < 2; i++)
            {
                using var deactivate = await db.Client.PatchAsJsonAsync(path + "/active", new { isActive = false });
                Assert.Equal(HttpStatusCode.NoContent, deactivate.StatusCode);
            }
            using var detail = await db.Client.GetAsync(path);
            var inactive = await detail.Content.ReadFromJsonAsync<StoreDto>();
            Assert.NotNull(inactive); Assert.False(inactive.IsActive); Assert.Equal(corporate, inactive.CorporateId); Assert.Equal("Yeni ad", inactive.Name);
            Assert.Null(await db.Get<IStoreCatalogReader>().GetStoreLocationAsync(id));
            using var visible = await db.Client.GetAsync(StoreTestDatabase.Path(corporate));
            Assert.Empty((await visible.Content.ReadFromJsonAsync<StorePageDto>())!.Items);
            using var all = await db.Client.GetAsync(StoreTestDatabase.Path(corporate) + "?includeInactive=true");
            Assert.Equal(id, Assert.Single((await all.Content.ReadFromJsonAsync<StorePageDto>())!.Items).Id);
            using var reopen = await db.Client.PatchAsJsonAsync(path + "/active", new { isActive = true });
            Assert.Equal(HttpStatusCode.NoContent, reopen.StatusCode);
            Assert.NotNull(await db.Get<IStoreCatalogReader>().GetStoreLocationAsync(id));
        }

        [StoreSqlFact]
        public async Task Other_corporate_ids_cannot_move_or_modify_a_store()
        {
            await using var db = new StoreTestDatabase();
            var a = await db.CorporateAsync(); var b = await db.CorporateAsync();
            db.ActAs(await db.UserAsync("CorporateOwner", a));
            var id = await db.CreateAsync(a);
            db.ActAs(await db.UserAsync("CorporateOwner", b));
            using var forbidden = await db.Client.PutAsJsonAsync(StoreTestDatabase.Path(a, id), StoreTestDatabase.ValidRequest());
            await AssertProblem(forbidden, 403);
            using var wrongParent = await db.Client.PutAsJsonAsync(StoreTestDatabase.Path(b, id), StoreTestDatabase.ValidRequest());
            await AssertProblem(wrongParent, 404);
            using var wrongActive = await db.Client.PatchAsJsonAsync(StoreTestDatabase.Path(b, id) + "/active", new { isActive = false });
            await AssertProblem(wrongActive, 404);
            using var bodyMove = await db.Client.PostAsJsonAsync(StoreTestDatabase.Path(b), new { name = "Taşı", addressText = "Adres", latitude = 41, longitude = 29, serviceRadiusKm = 5, corporateId = a });
            await AssertProblem(bodyMove, 400);
            await using var connection = await db.Connections.OpenAsync();
            await using var transaction = await connection.BeginTransactionAsync();
            Assert.Equal(a, (await db.Get<IStoreScopeReader>().GetScopeAsync(id, connection, transaction))?.CorporateId);
        }

        [StoreSqlFact]
        public async Task Store_staff_and_manager_can_read_only_assigned_active_store_and_cannot_manage()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var id = await db.CreateAsync(corporate); var other = await db.CreateAsync(corporate, "Diğer");
            foreach (var role in new[] { "StoreStaff", "StoreManager" })
            {
                db.ActAs(await db.UserAsync(role, storeId: id));
                using var allowed = await db.Client.GetAsync(StoreTestDatabase.Path(corporate, id));
                Assert.Equal(HttpStatusCode.OK, allowed.StatusCode);
                using var denied = await db.Client.GetAsync(StoreTestDatabase.Path(corporate, other));
                await AssertProblem(denied, 403);
                using var list = await db.Client.GetAsync(StoreTestDatabase.Path(corporate));
                await AssertProblem(list, 403);
                using var create = await db.Client.PostAsJsonAsync(StoreTestDatabase.Path(corporate), StoreTestDatabase.ValidRequest());
                await AssertProblem(create, 403);
                using var update = await db.Client.PutAsJsonAsync(StoreTestDatabase.Path(corporate, id), StoreTestDatabase.ValidRequest());
                await AssertProblem(update, 403);
                using var active = await db.Client.PatchAsJsonAsync(StoreTestDatabase.Path(corporate, id) + "/active", new { isActive = false });
                await AssertProblem(active, 403);
            }
        }

        [StoreSqlFact]
        public async Task Anonymous_requests_are_challenged_and_customer_cannot_manage()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            using var anonymous = await db.Client.PostAsJsonAsync(StoreTestDatabase.Path(corporate), StoreTestDatabase.ValidRequest());
            await AssertProblem(anonymous, 401); Assert.NotEmpty(anonymous.Headers.WwwAuthenticate);
            db.ActAs(await db.UserAsync("Customer"));
            using var denied = await db.Client.PostAsJsonAsync(StoreTestDatabase.Path(corporate), StoreTestDatabase.ValidRequest());
            await AssertProblem(denied, 403);
            db.ActAs(await db.UserAsync("PlatformAdmin"));
            await db.CreateAsync(corporate);
        }

        [StoreSqlFact]
        public async Task Invalid_fields_missing_measurements_unknown_fields_and_bad_pagination_are_rejected()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var invalidBodies = new object[]
            {
                new { name = " ", addressText = "Adres", latitude = 41, longitude = 29, serviceRadiusKm = 5 },
                new { name = "Dükkân", addressText = "Adres", latitude = 91, longitude = 29, serviceRadiusKm = 5 },
                new { name = "Dükkân", addressText = "Adres", latitude = 41, longitude = -181, serviceRadiusKm = 5 },
                new { name = "Dükkân", addressText = "Adres", latitude = 41, longitude = 29, serviceRadiusKm = 0 },
                new { name = "Dükkân", addressText = "Adres", latitude = 41.1234567m, longitude = 29, serviceRadiusKm = 5 },
                new { name = "Dükkân", addressText = "Adres", latitude = 41, longitude = 29, serviceRadiusKm = 5.001m },
                new { name = "Dükkân", addressText = "Adres", longitude = 29, serviceRadiusKm = 5 },
                new { name = "Dükkân", addressText = "Adres", latitude = 41, longitude = 29 },
                new { name = "Dükkân", addressText = "Adres", latitude = 41, longitude = 29, serviceRadiusKm = 5, userId = Guid.NewGuid() }
            };
            foreach (var body in invalidBodies)
            {
                using var response = await db.Client.PostAsJsonAsync(StoreTestDatabase.Path(corporate), body);
                await AssertProblem(response, 400);
            }
            foreach (var query in new[] { "page=0", "page=-1", "pageSize=0", "pageSize=101", "page=abc", "page=2147483648" })
            {
                using var response = await db.Client.GetAsync(StoreTestDatabase.Path(corporate) + "?" + query);
                await AssertProblem(response, 400);
            }
            var id = await db.CreateAsync(corporate);
            using var missingActive = await db.Client.PatchAsJsonAsync(StoreTestDatabase.Path(corporate, id) + "/active", new { });
            await AssertProblem(missingActive, 400);
        }

        [StoreSqlFact]
        public async Task Inactive_or_deleted_corporate_and_store_are_hidden_from_location_and_permission_reads()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate); db.ActAs(owner);
            var id = await db.CreateAsync(corporate);
            var reader = db.Get<IStoreCatalogReader>(); var checker = db.Get<IPermissionChecker>();
            Assert.True(await checker.HasPermissionAsync(owner, PermissionCodes.StoreView, storeId: id));
            foreach (var state in new[] { (Active: false, Deleted: (DateTime?)null), (Active: true, Deleted: (DateTime?)DateTime.UtcNow) })
            {
                await db.ExecuteAsync("SetStoreLifecycle.sql", new { Id = id, IsActive = state.Active, DeleteDate = state.Deleted });
                Assert.Null(await reader.GetStoreLocationAsync(id)); Assert.False(await reader.ServesLocationAsync(id, 41, 29));
                Assert.False(await checker.HasPermissionAsync(owner, PermissionCodes.StoreView, storeId: id));
            }
            await db.ExecuteAsync("SetStoreLifecycle.sql", new { Id = id, IsActive = true, DeleteDate = (DateTime?)null });
            foreach (var state in new[] { (Active: false, Deleted: (DateTime?)null), (Active: true, Deleted: (DateTime?)DateTime.UtcNow) })
            {
                await db.ExecuteAsync("SetCorporateLifecycle.sql", new { Id = corporate, IsActive = state.Active, DeleteDate = state.Deleted });
                Assert.Null(await reader.GetStoreLocationAsync(id)); Assert.False(await reader.ServesLocationAsync(id, 41, 29));
                Assert.False(await checker.HasPermissionAsync(owner, PermissionCodes.StoreView, storeId: id));
                using var response = await db.Client.GetAsync(StoreTestDatabase.Path(corporate));
                await AssertProblem(response, 403);
            }
        }

        [StoreSqlFact]
        public async Task Identity_staff_authorizer_uses_real_store_reader_and_rejects_other_corporate()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); var other = await db.CorporateAsync();
            var owner = await db.UserAsync("CorporateOwner", corporate); db.ActAs(owner);
            var id = await db.CreateAsync(corporate); var target = await db.UserAsync("Customer");
            var role = (await db.Get<IRoleRepository>().GetAllAsync()).Single(value => value.Code == "StoreStaff");
            await using var connection = await db.Connections.OpenAsync();
            await using var transaction = await connection.BeginTransactionAsync();
            var authorizer = db.Get<IStaffAssignmentAuthorizer>();
            Assert.True(await authorizer.CanManageAsync(owner, target, role.Id, corporate, id, connection, transaction));
            Assert.False(await authorizer.CanManageAsync(owner, target, role.Id, other, id, connection, transaction));
            Assert.False(await authorizer.CanManageAsync(owner, owner, role.Id, corporate, id, connection, transaction));
        }

        [StoreSqlFact]
        public async Task Location_reader_uses_supplied_transaction_and_checks_kilometre_coverage()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var id = await db.CreateAsync(corporate);
            var reader = db.Get<IStoreCatalogReader>();
            Assert.True(await reader.ServesLocationAsync(id, 41, 29));
            Assert.True(await reader.ServesLocationAsync(id, 41.04m, 29));
            Assert.False(await reader.ServesLocationAsync(id, 41.06m, 29));
            Assert.Null(await reader.GetStoreLocationAsync(Guid.NewGuid()));
            await Assert.ThrowsAsync<ArgumentException>(() => reader.GetStoreLocationAsync(Guid.Empty));
            await Assert.ThrowsAsync<ArgumentException>(() => reader.ServesLocationAsync(id, 91, 29));
            await using var connection = await db.Connections.OpenAsync(); await using var transaction = await connection.BeginTransactionAsync();
            var transactional = db.Get<ITransactionalStoreCatalogReader>();
            Assert.NotNull(await transactional.GetStoreLocationAsync(id, connection, transaction));
            Assert.True(await transactional.ServesLocationAsync(id, 41, 29, connection, transaction));
            await using var otherConnection = await db.Connections.OpenAsync();
            await Assert.ThrowsAsync<ArgumentException>(() => transactional.GetStoreLocationAsync(id, otherConnection, transaction));
            var mutation = await File.ReadAllTextAsync(System.IO.Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetStoreLifecycle.sql"));
            await connection.ExecuteAsync(mutation, new { Id = id, IsActive = false, DeleteDate = (DateTime?)null }, transaction);
            Assert.Null(await transactional.GetStoreLocationAsync(id, connection, transaction));
            await transaction.RollbackAsync();
            Assert.NotNull(await reader.GetStoreLocationAsync(id));
        }

        [StoreSqlFact]
        public async Task Store_seed_preserves_ids_and_does_not_restore_disabled_or_revoked_permissions()
        {
            await using var db = new StoreTestDatabase();
            await using var connection = await db.Connections.OpenAsync();
            var path = System.IO.Path.Combine(AppContext.BaseDirectory,"Fixtures");
            var snapshot = await File.ReadAllTextAsync(System.IO.Path.Combine(path,"ReadStoreManagementSeedState.sql"));
            var original = (await connection.QueryAsync<string>(snapshot)).ToArray(); Assert.Equal(2, original.Length);
            await using var transaction = await connection.BeginTransactionAsync();
            await connection.ExecuteAsync(await File.ReadAllTextAsync(System.IO.Path.Combine(path,"RevokeStoreManagementSeed.sql")), transaction: transaction);
            var revoked = (await connection.QueryAsync<string>(snapshot, transaction: transaction)).ToArray();
            var seed = await File.ReadAllTextAsync(System.IO.Path.Combine(path,"StoreManagementPermissionsSeed.sql"));
            await connection.ExecuteAsync(seed, transaction: transaction);
            await connection.ExecuteAsync(seed, transaction: transaction);
            Assert.Equal(revoked, (await connection.QueryAsync<string>(snapshot, transaction: transaction)).ToArray());
            await transaction.RollbackAsync();
            Assert.Equal(original, (await connection.QueryAsync<string>(snapshot)).ToArray());
        }

        [StoreSqlFact]
        public async Task Complete_reader_contract_filters_all_relations_and_resolves_override_prices()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); db.ActAs(await db.UserAsync("CorporateOwner",corporate));
            var storeId = await db.CreateAsync(corporate);
            var categoryId = Guid.NewGuid(); var productId = Guid.NewGuid(); var serviceId = Guid.NewGuid();
            var pairId = Guid.NewGuid(); var offeringId = Guid.NewGuid();
            object Parameters(string operation,string? hidden = null,decimal? priceOverride = null) => new
            {
                Operation = operation, Hidden = hidden, PriceOverride = priceOverride, StoreId = storeId,
                CategoryId = categoryId, ProductId = productId, ServiceId = serviceId, PairId = pairId, OfferingId = offeringId
            };
            try
            {
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql",Parameters("CREATE"));
                var reader = db.Get<IStoreCatalogReader>();
                Assert.Equal(125.25m,(await reader.GetOfferingAsync(storeId,productId,serviceId))?.UnitPrice);
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql",Parameters("CHANGE",priceOverride:149.50m));
                Assert.Equal(149.50m,(await reader.GetOfferingAsync(storeId,productId,serviceId))?.UnitPrice);
                foreach (var hidden in new[] { "category","product","service","pair","offering" })
                {
                    await db.ExecuteAsync("StoreOfferingReaderFixture.sql",Parameters("CHANGE",hidden));
                    Assert.Null(await reader.GetOfferingAsync(storeId,productId,serviceId));
                }
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql",Parameters("CHANGE"));
                await using var connection = await db.Connections.OpenAsync(); await using var transaction = await connection.BeginTransactionAsync();
                Assert.NotNull(await db.Get<ITransactionalStoreCatalogReader>().GetOfferingAsync(storeId,productId,serviceId,connection,transaction));
            }
            finally { await db.ExecuteAsync("StoreOfferingReaderFixture.sql",Parameters("DELETE")); }
        }

        [StoreSqlFact]
        public async Task Direct_sql_validation_and_missing_store_updates_do_not_create_extra_rows()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); db.ActAs(await db.UserAsync("CorporateOwner",corporate));
            var repository = db.Get<IStoreManagementRepository>();
            foreach (var data in new[]
            {
                new StoreWriteData("Geçersiz","Adres",91,29,5),
                new StoreWriteData("Geçersiz","Adres",90.0000000001m,29,5),
                new StoreWriteData("Geçersiz","Adres",41,29,5.0000000001m)
            })
            {
                var error = await Assert.ThrowsAsync<SqlException>(() => repository.SaveAsync(corporate,Guid.NewGuid(),data,true,CancellationToken.None));
                Assert.Equal(52300,error.Number);
            }
            using var missing = await db.Client.PutAsJsonAsync(StoreTestDatabase.Path(corporate,Guid.NewGuid()),StoreTestDatabase.ValidRequest());
            await AssertProblem(missing,404);
            await db.CreateAsync(corporate);
            using var page = await db.Client.GetAsync(StoreTestDatabase.Path(corporate));
            Assert.Equal(1,(await page.Content.ReadFromJsonAsync<StorePageDto>())!.TotalCount);
        }

        [StoreSqlFact]
        public async Task Revoked_corporate_membership_closes_write_access_without_changing_http_identity()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync(); var owner = await db.UserAsync("CorporateOwner",corporate); db.ActAs(owner);
            var id = await db.CreateAsync(corporate);
            var role = (await db.Get<IRoleRepository>().GetAllAsync()).Single(value => value.Code == "CorporateOwner");
            await db.Get<ITransactionRunner>().ExecuteAsync(async (connection,transaction,token) =>
            {
                await db.Get<IIdentityAccessRepository>().RevokeCorporateMembershipAsync(owner,corporate,role.Id,connection,transaction,token);
                return true;
            });
            using var denied = await db.Client.PutAsJsonAsync(StoreTestDatabase.Path(corporate,id),StoreTestDatabase.ValidRequest());
            await AssertProblem(denied,403);
        }

        private static async Task AssertProblem(HttpResponseMessage response, int status)
        {
            Assert.Equal(status, (int)response.StatusCode);
            Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
            using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            Assert.Equal(status, json.RootElement.GetProperty("status").GetInt32());
            foreach (var property in new[] { "type", "title", "detail", "instance", "code", "traceId" })
                Assert.False(string.IsNullOrWhiteSpace(json.RootElement.GetProperty(property).GetString()), property);
            if (status == 400) Assert.Equal(JsonValueKind.Object, json.RootElement.GetProperty("errors").ValueKind);
        }
    }
}

using Dapper;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class StoreSeedUpgradeTests
    {
        private const string LegacyDescription = "Şirkete bağlı fiziksel dükkânları yönetme";
        private static Task<string> Fixture(string name) => File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", name + ".sql"));

        [StoreSqlFact]
        public async Task Legacy_store_permission_upgrade_preserves_metadata_grant_ids_and_revocations()
        {
            await using var db = new StoreTestDatabase();
            await using var connection = await db.Connections.OpenAsync();
            var state = await Fixture("ReadStoreUpgradeState");
            var identities = await Fixture("ReadStoreManagementSeedState");
            var original = (await connection.QueryAsync<string>(identities)).ToArray();
            var seed = await Fixture("IdentityPermissionsSeed");
            foreach (var scenario in new[] { (Active: true, Deleted: false, Revoke: false), (Active: false, Deleted: false, Revoke: true), (Active: false, Deleted: true, Revoke: true) })
            {
                await using var transaction = await connection.BeginTransactionAsync();
                await connection.ExecuteAsync(await Fixture("PrepareLegacyPermission"), new
                {
                    Code = "store.manage", LegacyId = Guid.NewGuid(), Description = LegacyDescription,
                    IsActive = scenario.Active, DeleteDate = scenario.Deleted ? (DateTime?)DateTime.UtcNow : null, RevokeOwner = scenario.Revoke
                }, transaction);
                var before = (await connection.QueryAsync<string>(state, transaction: transaction)).ToArray();
                await connection.ExecuteAsync(seed, transaction: transaction);
                Assert.Equal(before, (await connection.QueryAsync<string>(state, transaction: transaction)).ToArray());
                var migrated = (await connection.QueryAsync<string>(identities, transaction: transaction)).ToArray();
                Assert.All(migrated, row => Assert.Equal(Guid.Parse("8b314bca-963a-5231-b7d0-768947eebe68"), Guid.Parse(row.Split('|')[0])));
                await connection.ExecuteAsync(seed, transaction: transaction);
                Assert.Equal(migrated, (await connection.QueryAsync<string>(identities, transaction: transaction)).ToArray());
                await transaction.RollbackAsync();
            }
            Assert.Equal(original, (await connection.QueryAsync<string>(identities)).ToArray());
        }

        [StoreSqlFact]
        public async Task Upgrade_rejects_unknown_data_and_rolls_back_if_a_later_seed_step_fails()
        {
            await using var db = new StoreTestDatabase();
            await using var connection = await db.Connections.OpenAsync();
            var state = await Fixture("ReadStoreManagementSeedState");
            var original = (await connection.QueryAsync<string>(state)).ToArray();
            var seed = await Fixture("IdentityPermissionsSeed");
            foreach (var scenario in new[] { "unknown", "occupied", "later_failure" })
            {
                await using var transaction = await connection.BeginTransactionAsync();
                async Task Prepare(string code, string description)
                {
                    await connection.ExecuteAsync(await Fixture("PrepareLegacyPermission"),
                        new { Code = code, LegacyId = Guid.NewGuid(), Description = description, IsActive = false, DeleteDate = (DateTime?)null, RevokeOwner = true }, transaction);
                }
                await Prepare("store.manage", scenario == "unknown" ? "Tanınmayan kayıt" : LegacyDescription);
                if (scenario == "occupied") await connection.ExecuteAsync(await Fixture("OccupyStorePermissionId"), transaction: transaction);
                if (scenario == "later_failure") await Prepare("catalog.manage", "Diğer iznin bozuk kimliği");
                var error = await Assert.ThrowsAsync<SqlException>(() => connection.ExecuteAsync(seed, transaction: transaction));
                Assert.Equal(52100, error.Number);
                await transaction.DisposeAsync();
                Assert.Equal(original, (await connection.QueryAsync<string>(state)).ToArray());
            }
        }
    }
}

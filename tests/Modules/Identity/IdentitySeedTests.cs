using Dapper;

namespace GiysiGo.Modules.Identity.Tests
{
    [Collection(nameof(IdentitySeedCollection))]
    public sealed class IdentitySeedTests
    {
        [SqlServerFact]
        public async Task Reapplying_seed_preserves_disabled_permissions_and_revoked_grants()
        {
            var fixtures = Path.Combine(AppContext.BaseDirectory, "Fixtures");
            var prepareSql = await File.ReadAllTextAsync(Path.Combine(fixtures, "PrepareSeedRedeploy.sql"));
            var seedSql = await File.ReadAllTextAsync(Path.Combine(fixtures, "IdentityPermissionsSeed.sql"));
            var snapshotSql = await File.ReadAllTextAsync(Path.Combine(fixtures, "ReadSeedUpgradeSnapshot.sql"));

            using var db = new IdentityDatabase();
            await using var connection = await db.Factory.OpenAsync();
            await using var transaction = await connection.BeginTransactionAsync();

            await connection.ExecuteAsync(prepareSql, transaction: transaction);
            var before = (await connection.QueryAsync<string>(snapshotSql, transaction: transaction)).ToArray();

            await connection.ExecuteAsync(seedSql, transaction: transaction);
            var after = (await connection.QueryAsync<string>(snapshotSql, transaction: transaction)).ToArray();

            Assert.Equal(before, after);
            await transaction.RollbackAsync();
        }
    }
}

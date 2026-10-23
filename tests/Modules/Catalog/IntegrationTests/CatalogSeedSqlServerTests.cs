using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;

namespace GiysiGo.Modules.Catalog.Tests.IntegrationTests
{
    public sealed class CatalogSeedSqlServerTests
    {
        [CatalogSqlServerFact]
        public async Task Seed_rejects_changed_stable_ids_without_partial_updates()
        {
            var factory = new SqlConnectionFactory(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
            await using var connection = await factory.OpenAsync();
            var seed = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Catalog", "CatalogSeed.sql"));
            var snapshotSql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "VerifyCatalogSeed.sql"));
            var before = (await connection.QueryAsync<string>(snapshotSql)).ToArray();
            foreach (var table in new[] { "SeedCategories", "SeedProducts", "SeedServices", "SeedPairs" })
            {
                var id = System.Text.RegularExpressions.Regex.Match(seed,
                    $@"INSERT @{table} [^\r\n]+ VALUES\s+\(N'(?<id>[a-f0-9-]{{36}})'").Groups["id"];
                Assert.True(id.Success);
                var invalidSeed = seed.Remove(id.Index, id.Length).Insert(id.Index, Guid.NewGuid().ToString());
                var error = await Assert.ThrowsAsync<Microsoft.Data.SqlClient.SqlException>(() => connection.ExecuteAsync(invalidSeed));
                Assert.Equal(51020, error.Number);
                var after = (await connection.QueryAsync<string>(snapshotSql)).ToArray();
                Assert.Equal(before, after);
                Assert.Equal(0, await connection.ExecuteScalarAsync<int>("SELECT @@TRANCOUNT;"));
            }
        }

        [CatalogSqlServerFact]
        public async Task Identity_seed_preserves_ids_and_does_not_restore_revoked_permissions_or_disabled_roles()
        {
            var factory = new SqlConnectionFactory(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
            await using var connection = await factory.OpenAsync();
            await using var transaction = await connection.BeginTransactionAsync();
            try
            {
                var seed = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Catalog", "IdentityPermissionsSeed.sql"));
                var snapshot = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "VerifyIdentityPermissionsSeed.sql"));
                await connection.ExecuteAsync(new CommandDefinition(seed, transaction: transaction));
                var before = (await connection.QueryAsync<string>(new CommandDefinition(snapshot, transaction: transaction))).ToArray();
                await connection.ExecuteAsync(new CommandDefinition(seed, transaction: transaction));
                var after = (await connection.QueryAsync<string>(new CommandDefinition(snapshot, transaction: transaction))).ToArray();
                Assert.Equal(before, after);
                var revoke = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "RevokeSeedPermissionFixture.sql"));
                await connection.ExecuteAsync(new CommandDefinition(revoke, transaction: transaction));
                await connection.ExecuteAsync(new CommandDefinition(seed, transaction: transaction));
                var verifyRevocation = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "VerifySeedRevocations.sql"));
                await connection.ExecuteAsync(new CommandDefinition(verifyRevocation, transaction: transaction));
            }
            finally
            {
                await transaction.RollbackAsync();
            }
        }

        [CatalogSqlServerFact]
        public async Task Checkout_requires_a_primary_service_and_accepts_base_or_alternative_with_add_on()
        {
            var factory = new SqlConnectionFactory(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
            var sql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "VerifyPrimarySelection.sql"));
            foreach (var primaryKind in new[] { "BASE", "ALTERNATIVE" })
            {
                await using var connection = await factory.OpenAsync();
                await using var transaction = await connection.BeginTransactionAsync();
                try
                {
                    await connection.ExecuteAsync(new CommandDefinition(sql, new { PrimaryKind = primaryKind }, transaction, commandType: CommandType.Text));
                }
                finally
                {
                    await transaction.RollbackAsync();
                }
            }
        }

        [CatalogSqlServerFact]
        public async Task Seed_repeats_without_duplicate_or_changed_ids_and_disables_previously_excluded_pair()
        {
            var factory = new SqlConnectionFactory(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
            await using var connection = await factory.OpenAsync();
            await using var transaction = await connection.BeginTransactionAsync();
            try
            {
                var seed = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Catalog", "CatalogSeed.sql"));
                await ExecuteAsync(seed);
                var before = await SnapshotAsync();
                var excludedFixture = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "CreateExcludedCatalogPair.sql"));
                await ExecuteAsync(excludedFixture);
                var disturbedFixture = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "DisturbCatalogSeed.sql"));
                await ExecuteAsync(disturbedFixture);
                await ExecuteAsync(seed);
                var after = await SnapshotAsync();
                Assert.Equal(before, after);
            }
            finally
            {
                await transaction.RollbackAsync();
            }

            async Task ExecuteAsync(string sql)
                => await connection.ExecuteAsync(new CommandDefinition(sql, transaction: transaction, commandType: CommandType.Text));

            async Task<string[]> SnapshotAsync()
            {
                var sql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "VerifyCatalogSeed.sql"));
                return (await connection.QueryAsync<string>(new CommandDefinition(sql, transaction: transaction, commandType: CommandType.Text))).ToArray();
            }
        }
    }
}

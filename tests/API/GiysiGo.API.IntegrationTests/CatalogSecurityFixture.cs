using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class CatalogSecurityFixture : IAsyncDisposable
    {
        public Guid FixtureId { get; } = Guid.NewGuid();
        public Guid AdminId { get; } = Guid.NewGuid();
        public Guid CustomerId { get; } = Guid.NewGuid();
        public Guid StaffId { get; } = Guid.NewGuid();
        public Guid OwnerId { get; } = Guid.NewGuid();
        public Guid CorporateA { get; } = Guid.NewGuid();
        public Guid CorporateB { get; } = Guid.NewGuid();
        public Guid StoreA { get; } = Guid.NewGuid();
        public Guid StoreB { get; } = Guid.NewGuid();
        public Guid StaffRoleId { get; } = Guid.NewGuid();
        public string CodePrefix => "catalog-security-" + FixtureId.ToString("N");

        public static async Task<CatalogSecurityFixture> CreateAsync()
        {
            var fixture = new CatalogSecurityFixture();
            await fixture.ExecuteAsync("CREATE");
            return fixture;
        }

        public async Task ExecuteAsync(string operation)
        {
            var factory = new SqlConnectionFactory(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
            await using var connection = await factory.OpenAsync();
            var sql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "CatalogSecurityFixture.sql"));
            await connection.ExecuteAsync(new CommandDefinition(sql,
                new { Operation = operation, AdminId, CustomerId, StaffId, OwnerId, CorporateA, CorporateB, StoreA, StoreB, StaffRoleId, CodePrefix },
                commandType: CommandType.Text));
        }

        public async ValueTask DisposeAsync() => await ExecuteAsync("CLEANUP");
    }
}

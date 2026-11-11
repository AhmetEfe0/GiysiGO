using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Catalog.Infrastructure;

namespace GiysiGo.Modules.Catalog.Tests.IntegrationTests
{
    public sealed class ReaderDatabase : IAsyncDisposable
    {
        public Guid CorporateId { get; } = Guid.NewGuid();
        public Guid StoreId { get; } = Guid.NewGuid();
        public Guid ProductId { get; } = Guid.NewGuid();
        public Guid ServiceId { get; } = Guid.NewGuid();
        private Guid CategoryId { get; } = Guid.NewGuid();
        private Guid PairId { get; } = Guid.NewGuid();
        private Guid OfferingId { get; } = Guid.NewGuid();
        public SqlConnectionFactory Connections { get; } = new(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!);
        public StoreCatalogReader Reader => new(new SqlTransactionRunner(Connections), new ReaderCorporateStatus(), new StoreScopeReader());
        public async Task ExecuteAsync(string operation, string? target = null, bool deleted = false, decimal? price = null,
            string unit = "PIECE", DbConnection? connection = null, DbTransaction? transaction = null)
        {
            var sql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory,"IntegrationTests","ReaderFixture.sql"));
            var parameters = new { Operation=operation, Target=target, Deleted=deleted, PriceOverride=price, PriceUnit=unit,
                CorporateId, StoreId, ProductId, ServiceId, CategoryId, PairId, OfferingId };
            if (connection is not null) await connection.ExecuteAsync(sql, parameters, transaction);
            else { await using var own = await Connections.OpenAsync(); await own.ExecuteAsync(sql,parameters); }
        }
        public async ValueTask DisposeAsync() => await ExecuteAsync("DELETE");
    }
}

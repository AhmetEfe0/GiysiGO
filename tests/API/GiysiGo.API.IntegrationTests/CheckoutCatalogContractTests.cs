using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.API.IntegrationTests
{
    [Collection("CatalogDatabase")]
    public sealed class CheckoutCatalogContractTests
    {
        [StoreSqlFact]
        public async Task Public_catalog_contracts_use_real_identity_and_the_callers_uncommitted_transaction()
        {
            await using var db = new StoreTestDatabase();
            var corporate = await db.CorporateAsync();
            db.ActAs(await db.UserAsync("CorporateOwner", corporate));
            var store = await db.CreateAsync(corporate);
            var category = Guid.NewGuid(); var product = Guid.NewGuid(); var service = Guid.NewGuid();
            var pair = Guid.NewGuid(); var offering = Guid.NewGuid();
            object Fixture(string operation, decimal? price = null) => new
            {
                Operation = operation, Hidden = (string?)null, PriceOverride = price,
                CategoryId = category, ProductId = product, ServiceId = service,
                PairId = pair, OfferingId = offering, StoreId = store
            };
            try
            {
                await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Fixture("CREATE"));
                var preview = db.Get<IStoreCatalogReader>();
                var checkout = db.Get<ITransactionalStoreCatalogReader>();
                Assert.Same(preview, checkout);
                await using var connection = await db.Connections.OpenAsync();
                await using (var transaction = await connection.BeginTransactionAsync())
                {
                    // Fixture writes are uncommitted; only a reader borrowing this transaction can see them.
                    var fixtureSql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "StoreOfferingReaderFixture.sql"));
                    await connection.ExecuteAsync(fixtureSql, Fixture("CHANGE", 149.50m), transaction);
                    var snapshot = await checkout.GetOfferingAsync(store, product, service, connection, transaction);
                    Assert.NotNull(snapshot);
                    Assert.Equal(149.50m, snapshot.UnitPrice); Assert.Equal("PIECE", snapshot.PriceUnit);
                    Assert.Equal(store, snapshot.StoreId); Assert.Equal(product, snapshot.ProductTypeId); Assert.Equal(service, snapshot.ServiceId);
                    Assert.NotNull(await checkout.GetStoreLocationAsync(store, connection, transaction));
                    Assert.True(await checkout.ServesLocationAsync(store, 41, 29, connection, transaction));
                    var corporateSql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "Fixtures", "SetCorporateLifecycle.sql"));
                    await connection.ExecuteAsync(corporateSql, new { Id = corporate, IsActive = false, DeleteDate = (DateTime?)null }, transaction);
                    Assert.Null(await checkout.GetOfferingAsync(store, product, service, connection, transaction));
                    Assert.Null(await checkout.GetStoreLocationAsync(store, connection, transaction));
                    Assert.False(await checkout.ServesLocationAsync(store, 41, 29, connection, transaction));
                    Assert.Same(connection, transaction.Connection);
                    await transaction.RollbackAsync();
                }
                Assert.Equal(125.25m, (await preview.GetOfferingAsync(store, product, service))?.UnitPrice);
                Assert.NotNull(await preview.GetStoreLocationAsync(store));
            }
            finally { await db.ExecuteAsync("StoreOfferingReaderFixture.sql", Fixture("DELETE")); }
        }
    }
}

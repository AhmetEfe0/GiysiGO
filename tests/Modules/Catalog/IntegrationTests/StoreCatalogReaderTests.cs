using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.Data.SqlClient;

namespace GiysiGo.Modules.Catalog.Tests.IntegrationTests
{
    [Collection("Catalog SQL")]
    public sealed class StoreCatalogReaderTests
    {
        [CatalogSqlServerFact]
        public async Task Offering_resolves_decimal_prices_units_and_rejects_wrong_combinations()
        {
            await using var db = new ReaderDatabase(); await db.ExecuteAsync("CREATE");
            var reader=db.Reader;
            foreach (var unit in new[] { "PIECE", "M2" })
            foreach (var price in new decimal?[] { null, 0m, 149.50m, 9999999999.99m })
            {
                await db.ExecuteAsync("STATE",price:price,unit:unit);
                var offering=await reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId);
                Assert.NotNull(offering); Assert.True(offering.IsActive);
                Assert.Equal(price ?? 125.25m,offering.UnitPrice); Assert.Equal(unit,offering.PriceUnit);
                Assert.Equal(db.StoreId,offering.StoreId); Assert.Equal(db.ProductId,offering.ProductTypeId); Assert.Equal(db.ServiceId,offering.ServiceId);
            }
            Assert.Null(await reader.GetOfferingAsync(Guid.NewGuid(),db.ProductId,db.ServiceId));
            Assert.Null(await reader.GetOfferingAsync(db.StoreId,Guid.NewGuid(),db.ServiceId));
            Assert.Null(await reader.GetOfferingAsync(db.StoreId,db.ProductId,Guid.NewGuid()));
            Assert.Null(await reader.GetStoreLocationAsync(Guid.NewGuid()));
            Assert.False(await reader.ServesLocationAsync(Guid.NewGuid(),41,29));
        }

        [CatalogSqlServerFact]
        public async Task Inactive_and_deleted_links_return_null_or_false_consistently()
        {
            await using var db = new ReaderDatabase(); await db.ExecuteAsync("CREATE");
            foreach (var target in new[] { "corporate","store","offering","pair","product","category","service" })
            foreach (var deleted in new[] { false,true })
            {
                await db.ExecuteAsync("STATE",target,deleted);
                Assert.Null(await db.Reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId));
                if (target is "corporate" or "store")
                {
                    Assert.Null(await db.Reader.GetStoreLocationAsync(db.StoreId));
                    Assert.False(await db.Reader.ServesLocationAsync(db.StoreId,41,29));
                }
            }
            await db.ExecuteAsync("STATE");
            Assert.NotNull(await db.Reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId));
            var location=await db.Reader.GetStoreLocationAsync(db.StoreId);
            Assert.NotNull(location); Assert.True(location.IsActive); Assert.Equal("Test adresi",location.AddressText);
            Assert.Equal(41m,location.Latitude); Assert.Equal(29m,location.Longitude);
            Assert.True(await db.Reader.ServesLocationAsync(db.StoreId,41,29));
            Assert.True(await db.Reader.ServesLocationAsync(db.StoreId,41.04m,29));
            Assert.False(await db.Reader.ServesLocationAsync(db.StoreId,41.06m,29));
            Assert.False(await db.Reader.ServesLocationAsync(db.StoreId,-90,180));
        }

        [CatalogSqlServerFact]
        public async Task Checkout_reads_hold_price_and_every_active_link_until_caller_finishes()
        {
            await using var db = new ReaderDatabase(); await db.ExecuteAsync("CREATE");
            foreach (var target in new[] { "price","override","offering","pair","product","category","service","store","corporate","radius","location" })
            {
                await db.ExecuteAsync("STATE");
                await using var connection=await db.Connections.OpenAsync();
                await using var transaction=await connection.BeginTransactionAsync();
                var reader=(ITransactionalStoreCatalogReader)db.Reader;
                var snapshot=await reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId,connection,transaction);
                Assert.NotNull(snapshot);
                var location=await reader.GetStoreLocationAsync(db.StoreId,connection,transaction);
                Assert.NotNull(location);
                Assert.True(await reader.ServesLocationAsync(db.StoreId,41.04m,29,connection,transaction));
                var blocked=await Assert.ThrowsAsync<SqlException>(()=>db.ExecuteAsync("CHANGE",target));
                Assert.Equal(1222,blocked.Number);
                // The reader leaves the caller's transaction open and usable.
                await transaction.CommitAsync();
                await db.ExecuteAsync("CHANGE",target);
                Assert.Equal(125.25m,snapshot.UnitPrice); Assert.Equal("Test adresi",location.AddressText);
                if (target is "price" or "override")
                    Assert.Equal(target=="price"?199.99m:149.50m,(await db.Reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId))?.UnitPrice);
                else if (target=="radius") Assert.False(await db.Reader.ServesLocationAsync(db.StoreId,41.04m,29));
                else if (target=="location") Assert.Equal("Yeni adres",(await db.Reader.GetStoreLocationAsync(db.StoreId))?.AddressText);
                else Assert.Null(await db.Reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId));
            }
        }

        [CatalogSqlServerFact]
        public async Task Location_and_coverage_each_protect_their_own_store_reads()
        {
            await using var db=new ReaderDatabase(); await db.ExecuteAsync("CREATE");
            foreach (var coverage in new[] { false,true })
            foreach (var target in new[] { "store","corporate","radius","location" })
            {
                await db.ExecuteAsync("STATE");
                await using var connection=await db.Connections.OpenAsync();
                await using var transaction=await connection.BeginTransactionAsync();
                var reader=(ITransactionalStoreCatalogReader)db.Reader;
                if (coverage) Assert.True(await reader.ServesLocationAsync(db.StoreId,41.04m,29,connection,transaction));
                else Assert.NotNull(await reader.GetStoreLocationAsync(db.StoreId,connection,transaction));
                var blocked=await Assert.ThrowsAsync<SqlException>(()=>db.ExecuteAsync("CHANGE",target));
                Assert.Equal(1222,blocked.Number);
                await transaction.RollbackAsync();
                await db.ExecuteAsync("CHANGE",target);
            }
        }

        [CatalogSqlServerFact]
        public async Task Database_lock_errors_are_not_hidden_as_missing_offerings_or_coverage()
        {
            await using var db = new ReaderDatabase();
            await db.ExecuteAsync("CREATE");
            foreach (var method in new[] { "offering", "location", "coverage" })
            {
                await using var writer = await db.Connections.OpenAsync();
                await using var writeTransaction = await writer.BeginTransactionAsync();
                await db.ExecuteAsync("CHANGE", "location", connection: writer, transaction: writeTransaction);
                await using var connection = await db.Connections.OpenAsync();
                await connection.ExecuteAsync(await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "IntegrationTests", "ReaderLockTimeout.sql")));
                await using var transaction = await connection.BeginTransactionAsync();
                var reader = (ITransactionalStoreCatalogReader)db.Reader;
                var failure = await Assert.ThrowsAsync<SqlException>(async () =>
                {
                    if (method == "offering") await reader.GetOfferingAsync(db.StoreId, db.ProductId, db.ServiceId, connection, transaction);
                    else if (method == "location") await reader.GetStoreLocationAsync(db.StoreId, connection, transaction);
                    else await reader.ServesLocationAsync(db.StoreId, 41, 29, connection, transaction);
                });
                Assert.Equal(1222, failure.Number);
                await transaction.RollbackAsync();
                await writeTransaction.RollbackAsync();
            }
        }

        [CatalogSqlServerFact]
        public async Task Reader_preserves_caller_rollback_and_propagates_validation_and_cancellation()
        {
            await using var db = new ReaderDatabase(); await db.ExecuteAsync("CREATE");
            var reader=(ITransactionalStoreCatalogReader)db.Reader;
            await using var connection=await db.Connections.OpenAsync();
            await using var other=await db.Connections.OpenAsync();
            await using var transaction=await connection.BeginTransactionAsync();
            await db.ExecuteAsync("STATE",price:149.50m,connection:connection,transaction:transaction);
            Assert.Equal(149.50m,(await reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId,connection,transaction))?.UnitPrice);
            await Assert.ThrowsAsync<ArgumentException>(()=>reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId,other,transaction));
            await Assert.ThrowsAsync<ArgumentException>(()=>reader.GetStoreLocationAsync(Guid.Empty,connection,transaction));
            await Assert.ThrowsAsync<ArgumentException>(()=>reader.ServesLocationAsync(db.StoreId,91,29,connection,transaction));
            await Assert.ThrowsAsync<ArgumentException>(()=>reader.ServesLocationAsync(db.StoreId,41,-181,connection,transaction));
            using var cancelled=new CancellationTokenSource(); cancelled.Cancel();
            await Assert.ThrowsAnyAsync<OperationCanceledException>(()=>reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId,connection,transaction,cancelled.Token));
            await transaction.RollbackAsync();
            Assert.Equal(125.25m,(await db.Reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId))?.UnitPrice);
            await Assert.ThrowsAsync<ArgumentException>(()=>reader.GetStoreLocationAsync(db.StoreId,connection,transaction));
            await using var failing=await connection.BeginTransactionAsync();
            failing.Dispose();
            await Assert.ThrowsAsync<ArgumentException>(()=>reader.GetOfferingAsync(db.StoreId,db.ProductId,db.ServiceId,connection,failing));
        }
    }
}

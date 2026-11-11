using System.Data;
using System.Data.Common;
using System.Diagnostics.CodeAnalysis;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Ordering.Application;
using GiysiGo.Modules.Ordering.Application.Contracts;
using GiysiGo.Modules.Ordering.Domain;

namespace GiysiGo.Modules.Ordering.Tests
{
    public sealed class CartCommandServiceTests
    {
        [Fact]
        public async Task Add_item_keeps_each_physical_item_as_a_separate_command()
        {
            var repository = new FakeCartRepository();
            var service = CreateService(repository);
            var cartId = Guid.NewGuid();
            var productTypeId = Guid.NewGuid();

            await service.AddItemAsync(new CartItem { Id = Guid.NewGuid(), CartId = cartId, ProductTypeId = productTypeId }, 0);
            await service.AddItemAsync(new CartItem { Id = Guid.NewGuid(), CartId = cartId, ProductTypeId = productTypeId }, 1);

            Assert.Equal(2, repository.AddItemCalls);
            Assert.NotEqual(repository.AddedItems[0].Id, repository.AddedItems[1].Id);
            Assert.All(repository.AddedItems, item => Assert.Equal(productTypeId, item.ProductTypeId));
        }

        [Theory]
        [InlineData(0)]
        [InlineData(-1)]
        public async Task Add_item_rejects_non_positive_measurements(decimal measurement)
        {
            var repository = new FakeCartRepository();
            var service = CreateService(repository);

            await Assert.ThrowsAsync<ArgumentOutOfRangeException>(() => service.AddItemAsync(
                new CartItem { Id = Guid.NewGuid(), CartId = Guid.NewGuid(), ProductTypeId = Guid.NewGuid(), CustomerMeasurement = measurement }, 0));
            Assert.Equal(0, repository.AddItemCalls);
        }

        [Fact]
        public async Task Create_cart_requires_an_owned_address_before_persisting()
        {
            var repository = new FakeCartRepository();
            var service = CreateService(repository, addressMissing: true);

            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.CreateAsync(Guid.NewGuid(), Guid.NewGuid(), null, null));
            Assert.Equal(0, repository.CreateCalls);
        }

        [Fact]
        public async Task Create_cart_persists_the_authenticated_customer_and_selected_store()
        {
            var repository = new FakeCartRepository();
            var service = CreateService(repository);
            var storeId = Guid.NewGuid();
            var addressId = Guid.NewGuid();

            var cartId = await service.CreateAsync(storeId, addressId, null, null);

            Assert.Equal(repository.CreatedCart!.Id, cartId);
            Assert.Equal(storeId, repository.CreatedCart.StoreId);
            Assert.Equal(addressId, repository.CreatedCart.AddressId);
            Assert.Equal(FakeCurrentUser.CustomerId, repository.CreatedCart.CustomerId);
        }

        [Fact]
        public async Task Add_service_validates_the_selected_catalog_offering_inside_the_cart_transaction()
        {
            var context = new CartItemCatalogContext(Guid.NewGuid(), Guid.NewGuid());
            var repository = new FakeCartRepository { CatalogContext = context };
            var serviceId = Guid.NewGuid();
            var offeringId = Guid.NewGuid();
            var offering = new StoreOfferingSnapshot(context.StoreId, context.ProductTypeId, serviceId, 18.50m, "PIECE", true)
            {
                StoreOfferingId = offeringId,
                SelectionKind = "BASE"
            };
            var catalog = new FakeCatalogReader { OfferingById = offering };
            var service = CreateService(repository, catalog: catalog);
            var cartItemService = new CartItemService { Id = Guid.NewGuid(), CartItemId = Guid.NewGuid(), StoreOfferingId = offeringId };

            await service.AddServiceAsync(cartItemService, serviceId, 0);

            Assert.Equal(1, repository.AddServiceCalls);
            Assert.Equal(serviceId, repository.AddedServiceId);
        }

        [Fact]
        public async Task Add_service_rejects_missing_or_inactive_catalog_offerings()
        {
            var repository = new FakeCartRepository();
            var service = CreateService(repository);
            var cartItemService = new CartItemService { Id = Guid.NewGuid(), CartItemId = Guid.NewGuid(), StoreOfferingId = Guid.NewGuid() };

            await Assert.ThrowsAsync<InvalidOperationException>(() => service.AddServiceAsync(cartItemService, Guid.NewGuid(), 0));
            Assert.Equal(0, repository.AddServiceCalls);
        }

        private static CartCommandService CreateService(FakeCartRepository repository, bool addressMissing = false, FakeCatalogReader? catalog = null)
        {
            catalog ??= new FakeCatalogReader();
            return new(new InlineTransactionRunner(), repository, null!, new FakeAddressReader(addressMissing), catalog, catalog, new FakeCurrentUser());
        }

        private sealed class InlineTransactionRunner : ITransactionRunner
        {
            private readonly StubDbConnection _connection = new();
            private readonly StubDbTransaction _transaction;
            public InlineTransactionRunner() => _transaction = new StubDbTransaction(_connection);
            public Task<TResult> ExecuteAsync<TResult>(Func<DbConnection, DbTransaction, CancellationToken, Task<TResult>> action, CancellationToken cancellationToken = default) =>
                action(_connection, _transaction, cancellationToken);
            public Task<TResult> ExecuteAsync<TResult>(Func<DbConnection, DbTransaction, CancellationToken, Task<TResult>> action, System.Data.IsolationLevel isolationLevel, CancellationToken cancellationToken = default) =>
                action(_connection, _transaction, cancellationToken);
        }

        private sealed class FakeCartRepository : ICartCommandRepository
        {
            public int CreateCalls { get; private set; }
            public int AddItemCalls { get; private set; }
            public int AddServiceCalls { get; private set; }
            public Cart? CreatedCart { get; private set; }
            public Guid AddedServiceId { get; private set; }
            public CartItemCatalogContext CatalogContext { get; set; } = new(Guid.NewGuid(), Guid.NewGuid());
            public List<CartItem> AddedItems { get; } = [];
            public Task<Guid> CreateAsync(Cart cart, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            {
                CreateCalls++;
                CreatedCart = cart;
                return Task.FromResult(cart.Id);
            }
            public Task AddItemAsync(CartItem item, Guid customerId, int expectedCartVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            {
                AddItemCalls++;
                AddedItems.Add(item);
                return Task.CompletedTask;
            }
            public Task<CartItemCatalogContext?> GetCartItemCatalogContextAsync(Guid cartItemId, Guid customerId, int expectedCartVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.FromResult<CartItemCatalogContext?>(CatalogContext);
            public Task AddServiceAsync(CartItemService service, Guid serviceId, Guid customerId, int expectedCartVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            {
                AddServiceCalls++;
                AddedServiceId = serviceId;
                return Task.CompletedTask;
            }
            public Task RemoveServiceAsync(Guid cartId, Guid cartItemId, Guid serviceId, Guid customerId, int expectedCartVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.CompletedTask;
            public Task AddPhotoAsync(CartItemPhoto photo, Guid customerId, int expectedCartVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.CompletedTask;
            public Task RemovePhotoAsync(Guid cartId, Guid cartItemId, Guid photoId, Guid customerId, int expectedCartVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.CompletedTask;
            public Task RemoveItemAsync(Guid cartId, Guid itemId, Guid customerId, int expectedVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.CompletedTask;
            public Task SetAddressAndPickupWindowAsync(Guid cartId, Guid customerId, Guid addressId, DateTime? pickupStartUtc, DateTime? pickupEndUtc, int expectedVersion, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.CompletedTask;
        }

        private sealed class FakeAddressReader(bool missing) : ICustomerAddressReader
        {
            public Task<CustomerAddressSnapshot?> GetOwnedAddressAsync(Guid customerId, Guid addressId, CancellationToken cancellationToken = default) =>
                Task.FromResult<CustomerAddressSnapshot?>(missing ? null : new(addressId, customerId, "Address", 41m, 29m, "Name", "Phone"));
        }

        private sealed class FakeCatalogReader : IStoreCatalogReader, ITransactionalStoreCatalogReader
        {
            public StoreOfferingSnapshot? OfferingById { get; set; }
            public Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, CancellationToken cancellationToken = default) => Task.FromResult<StoreOfferingSnapshot?>(null);
            public Task<StoreOfferingSnapshot?> GetOfferingByIdAsync(Guid storeId, Guid productTypeId, Guid storeOfferingId, CancellationToken cancellationToken = default) => Task.FromResult(OfferingById);
            public Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, CancellationToken cancellationToken = default) => Task.FromResult<StoreLocationSnapshot?>(new(storeId, "Store", 41m, 29m, true));
            public Task<bool> ServesLocationAsync(Guid storeId, decimal latitude, decimal longitude, CancellationToken cancellationToken = default) => Task.FromResult(true);
            public Task<StoreOfferingSnapshot?> GetOfferingAsync(Guid storeId, Guid productTypeId, Guid serviceId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.FromResult<StoreOfferingSnapshot?>(null);
            public Task<StoreOfferingSnapshot?> GetOfferingByIdAsync(Guid storeId, Guid productTypeId, Guid storeOfferingId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.FromResult(OfferingById);
            public Task<StoreLocationSnapshot?> GetStoreLocationAsync(Guid storeId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.FromResult<StoreLocationSnapshot?>(new(storeId, "Store", 41m, 29m, true));
            public Task<bool> ServesLocationAsync(Guid storeId, decimal latitude, decimal longitude, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default) => Task.FromResult(true);
        }

        private sealed class FakeCurrentUser : ICurrentUser
        {
            public static Guid CustomerId { get; } = Guid.NewGuid();
            public Guid? UserId => CustomerId;
            public bool IsAuthenticated => true;
        }

        private sealed class StubDbConnection : DbConnection
        {
            [AllowNull] public override string ConnectionString { get; set; } = string.Empty;
            public override string Database => "test";
            public override string DataSource => "test";
            public override string ServerVersion => "1";
            public override ConnectionState State => ConnectionState.Open;
            public override void ChangeDatabase(string databaseName) { }
            public override void Close() { }
            public override void Open() { }
            protected override DbTransaction BeginDbTransaction(IsolationLevel isolationLevel) => new StubDbTransaction(this);
            protected override DbCommand CreateDbCommand() => throw new NotSupportedException();
        }

        private sealed class StubDbTransaction(DbConnection connection) : DbTransaction
        {
            public override IsolationLevel IsolationLevel => IsolationLevel.ReadCommitted;
            protected override DbConnection DbConnection => connection;
            public override void Commit() { }
            public override void Rollback() { }
        }
    }
}

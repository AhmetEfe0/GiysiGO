using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Offerings;
using GiysiGo.Modules.Catalog.Application.Repositories;

namespace GiysiGo.Modules.Catalog.Tests
{
    public sealed class StoreOfferingManagementTests
    {
        [Theory]
        [InlineData("save")]
        [InlineData("active")]
        [InlineData("price")]
        [InlineData("list")]
        public async Task Other_store_staff_cannot_read_or_write(string operation)
        {
            var corporate = Guid.NewGuid(); var ownStore = Guid.NewGuid(); var otherStore = Guid.NewGuid();
            var repository = new OfferingRepositoryFake();
            var permissions = new ScopedPermissions(corporate, ownStore);
            var service = new StoreOfferingManagementService(new User(), permissions, repository);
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => Invoke(service, operation, corporate, otherStore));
            Assert.Equal(0, repository.Calls);
            Assert.Equal((PermissionCodes.StoreOfferingManage, corporate, otherStore), permissions.LastScope);
        }

        [Fact]
        public async Task Price_reset_passes_null_and_does_not_change_active_state()
        {
            var corporate = Guid.NewGuid(); var store = Guid.NewGuid();
            var repository = new OfferingRepositoryFake();
            var service = new StoreOfferingManagementService(new User(), new ScopedPermissions(corporate, store), repository);
            await service.SetPriceAsync(corporate, store, Guid.NewGuid(), null, default);
            Assert.Equal("SET_PRICE", repository.Operation); Assert.Null(repository.Price); Assert.Null(repository.Active);
        }

        [Theory]
        [InlineData("-0.01")]
        [InlineData("1.001")]
        [InlineData("10000000000")]
        public async Task Invalid_prices_never_reach_repository(string value)
        {
            var corporate = Guid.NewGuid(); var store = Guid.NewGuid();
            var repository = new OfferingRepositoryFake();
            var service = new StoreOfferingManagementService(new User(), new ScopedPermissions(corporate, store), repository);
            var price = decimal.Parse(value, System.Globalization.CultureInfo.InvariantCulture);
            await Assert.ThrowsAsync<ArgumentException>(() => service.SaveAsync(corporate, store, Guid.NewGuid(), true, price, default));
            await Assert.ThrowsAsync<ArgumentException>(() => service.SetPriceAsync(corporate, store, Guid.NewGuid(), price, default));
            Assert.Equal(0, repository.Calls);
        }

        [Fact]
        public async Task Anonymous_user_is_rejected_even_if_checker_would_allow()
        {
            var corporate = Guid.NewGuid(); var store = Guid.NewGuid(); var repository = new OfferingRepositoryFake();
            var service = new StoreOfferingManagementService(new User(false), new ScopedPermissions(corporate, store), repository);
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.SaveAsync(corporate, store, Guid.NewGuid(), true, 0, default));
            Assert.Equal(0, repository.Calls);
        }

        private static Task Invoke(StoreOfferingManagementService service, string operation, Guid corporate, Guid store) => operation switch
        {
            "save" => service.SaveAsync(corporate, store, Guid.NewGuid(), true, 10, default),
            "active" => service.SetActiveAsync(corporate, store, Guid.NewGuid(), false, default),
            "price" => service.SetPriceAsync(corporate, store, Guid.NewGuid(), null, default),
            _ => service.ListAsync(corporate, store, 1, 20, default)
        };
    }
}

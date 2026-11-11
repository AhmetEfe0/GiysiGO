using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Application.Models;
using GiysiGo.Modules.Identity.Domain.Entities;
using Microsoft.Data.SqlClient;

namespace GiysiGo.Modules.Identity.Tests
{
    [Collection(nameof(IdentityDatabaseCollection))]
    public sealed class CustomerAddressFeatureTests
    {
        [SqlServerFact]
        public async Task Address_readers_enforce_owner_and_share_checkout_transaction()
        {
            using var db = new IdentityDatabase();
            var owner = await db.CreateUserAsync();
            var other = await db.CreateUserAsync();
            var self = db.Get<ICustomerSelfService>();
            var input = new CustomerAddressInput("Ev", "İstanbul", 41.123456m, 29.654321m, "Ada", "5550000000");
            var addressId = await self.CreateAddressAsync(owner, input);
            var reader = db.Get<ICustomerAddressReader>();
            var transactional = db.Get<ITransactionalCustomerAddressReader>();
            Assert.Equal("İstanbul", (await reader.GetOwnedAddressAsync(owner, addressId))?.AddressText);
            Assert.Null(await reader.GetOwnedAddressAsync(other, addressId));
            await Assert.ThrowsAsync<ArgumentException>(() => reader.GetOwnedAddressAsync(Guid.Empty, addressId));
            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                Assert.Equal("Ada", (await transactional.GetOwnedAddressAsync(owner, addressId, connection, transaction, token))?.ContactName);
                Assert.Null(await transactional.GetOwnedAddressAsync(other, addressId, connection, transaction, token));
                return true;
            });
            Assert.False(await self.UpdateAddressAsync(other, addressId, input with { AddressText = "Başka" }));
            Assert.False(await self.DeleteAddressAsync(other, addressId));
            Assert.Equal("İstanbul", (await self.GetAddressAsync(owner, addressId))?.AddressText);
            await using (var connection = await db.Factory.OpenAsync())
            await using (var transaction = await connection.BeginTransactionAsync())
            {
                await using var otherConnection = await db.Factory.OpenAsync();
                await Assert.ThrowsAsync<ArgumentException>(() =>
                    transactional.GetOwnedAddressAsync(owner, addressId, otherConnection, transaction));
                var changed = (await self.GetAddressAsync(owner, addressId))!;
                changed.AddressText = "Transaction adresi";
                await db.Get<ICustomerAddressRepository>().UpdateOwnedAsync(owner, changed, connection, transaction);
                Assert.Equal(changed.AddressText,
                    (await transactional.GetOwnedAddressAsync(owner, addressId, connection, transaction))?.AddressText);
                await transaction.RollbackAsync();
            }
            Assert.Equal("İstanbul", (await reader.GetOwnedAddressAsync(owner, addressId))?.AddressText);
            var inactiveId = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                db.Get<ICustomerAddressRepository>().InsertAsync(owner, new CustomerAddress
                {
                    Label = "Pasif", AddressText = "Gizli", ContactName = "Ada", ContactPhone = "5550000000",
                    Latitude = 41, Longitude = 29, IsActive = false
                }, connection, transaction, token));
            Assert.Null(await reader.GetOwnedAddressAsync(owner, inactiveId));
            Assert.False(await self.UpdateAddressAsync(owner, inactiveId, input));
            Assert.False(await self.DeleteAddressAsync(owner, inactiveId));
            Assert.True(await self.DeleteAddressAsync(owner, addressId));
            Assert.Null(await reader.GetOwnedAddressAsync(owner, addressId));
            Assert.Empty(await self.GetAddressesAsync(owner));
        }

        [SqlServerFact]
        public async Task Address_validation_and_profile_update_preserve_sensitive_fields()
        {
            using var db = new IdentityDatabase();
            var owner = await db.CreateUserAsync();
            var self = db.Get<ICustomerSelfService>();
            var input = new CustomerAddressInput("Ev", "İstanbul", 91, 29, "Ada", "5550000000");
            await Assert.ThrowsAsync<ArgumentException>(() => self.CreateAddressAsync(owner, input));
            await Assert.ThrowsAsync<ArgumentException>(() => self.CreateAddressAsync(owner,
                input with { Latitude = 41, Longitude = 29.1234567m }));
            await Assert.ThrowsAsync<ArgumentException>(() => self.CreateAddressAsync(owner,
                input with { Latitude = 41, ContactPhone = "abc" }));
            await Assert.ThrowsAsync<ArgumentException>(() => self.CreateAddressAsync(owner,
                input with { Latitude = 41, ContactPhone = "+123" }));
            Assert.Empty(await self.GetAddressesAsync(owner));
            var original = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                db.Get<IUserRepository>().GetByIdAsync(owner, connection, transaction, token));
            foreach (var invalidEmail in new[] { "a@b", " a@b " })
                await Assert.ThrowsAsync<ArgumentException>(() => self.UpdateProfileAsync(owner, invalidEmail));
            Assert.Equal(original!.Email, (await self.GetProfileAsync(owner))?.Email);
            var email = $"new-{Guid.NewGuid():N}@example.test";
            Assert.Equal(email, (await self.UpdateProfileAsync(owner, email))?.Email);
            var updated = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                db.Get<IUserRepository>().GetByIdAsync(owner, connection, transaction, token));
            Assert.Equal(original?.PasswordHash, updated?.PasswordHash);
            Assert.Equal(original?.IsActive, updated?.IsActive);
            Assert.NotNull(updated?.UpdateDate);
            Assert.Equal(owner, (await self.GetProfileAsync(owner))?.Id);
            var second = await db.CreateUserAsync();
            var secondEmail = (await self.GetProfileAsync(second))!.Email;
            var conflict = await Assert.ThrowsAsync<SqlException>(() => self.UpdateProfileAsync(owner, secondEmail.ToUpperInvariant()));
            Assert.Contains(conflict.Number, new[] { 2601, 2627 });
            Assert.Equal(email, (await self.GetProfileAsync(owner))?.Email);
        }

        [SqlServerFact]
        public async Task Address_page_counts_all_owned_addresses_and_returns_only_requested_rows()
        {
            using var db = new IdentityDatabase();
            var owner = await db.CreateUserAsync();
            var other = await db.CreateUserAsync();
            var self = db.Get<ICustomerSelfService>();
            var input = new CustomerAddressInput("Ev", "İstanbul", 41, 29, "Ada", "+905550000000");
            var first = await self.CreateAddressAsync(owner, input);
            var second = await self.CreateAddressAsync(owner, input with { Label = "İş" });
            await self.CreateAddressAsync(other, input);

            var page = await self.GetAddressPageAsync(owner, 1, 1);
            Assert.Equal(2, page.TotalCount);
            Assert.Single(page.Items);
            Assert.Contains(page.Items[0].Id, new[] { first, second });
            var next = await self.GetAddressPageAsync(owner, 2, 1);
            Assert.Equal(2, next.TotalCount);
            Assert.Single(next.Items);
            Assert.NotEqual(page.Items[0].Id, next.Items[0].Id);
            var beyond = await self.GetAddressPageAsync(owner, 3, 1);
            Assert.Equal(2, beyond.TotalCount);
            Assert.Empty(beyond.Items);
            Assert.Empty((await self.GetAddressPageAsync(other, 2, 1)).Items);
        }

        [SqlServerFact]
        public async Task Updating_or_deleting_address_does_not_mutate_order_snapshot()
        {
            using var db = new IdentityDatabase();
            var owner = await db.CreateUserAsync();
            var corporateId = await db.Get<ICorporateRepository>().InsertAsync(new() { Name = "Snapshot test" });
            var storeId = await db.CreateStoreAsync(corporateId);
            var self = db.Get<ICustomerSelfService>();
            var input = new CustomerAddressInput("Ev", "Eski adres", 41m, 29m, "Ada", "5550000000");
            var addressId = await self.CreateAddressAsync(owner, input);
            var fixture = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Fixtures", "CreateOrderAddressSnapshot.sql"));
            var snapshotId = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                connection.QuerySingleAsync<Guid>(new CommandDefinition(fixture,
                    new { CustomerId = owner, StoreId = storeId, AddressId = addressId,
                        input.AddressText, input.Latitude, input.Longitude, input.ContactName, input.ContactPhone },
                    transaction, cancellationToken: token)));
            await self.UpdateAddressAsync(owner, addressId, input with { AddressText = "Yeni adres", ContactName = "Ali" });
            await self.DeleteAddressAsync(owner, addressId);
            var read = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Fixtures", "ReadOrderAddressSnapshot.sql"));
            var snapshot = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                connection.QuerySingleAsync<OrderAddressValues>(new CommandDefinition(read,
                    new { SnapshotId = snapshotId }, transaction, cancellationToken: token)));
            Assert.Equal("Eski adres", snapshot.AddressText);
            Assert.Equal("Ada", snapshot.ContactName);
            Assert.Equal(41m, snapshot.Latitude);
            Assert.Equal(29m, snapshot.Longitude);
        }

    }
}

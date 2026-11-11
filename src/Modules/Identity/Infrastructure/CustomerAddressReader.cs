using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class CustomerAddressReader(ITransactionRunner transactions, ICustomerAddressRepository addresses)
        : ICustomerAddressReader, ITransactionalCustomerAddressReader
    {
        public Task<CustomerAddressSnapshot?> GetOwnedAddressAsync(Guid customerId, Guid addressId,
            CancellationToken cancellationToken = default)
        {
            ValidateIds(customerId, addressId);
            return transactions.ExecuteAsync((connection, transaction, token) =>
                GetOwnedAddressAsync(customerId, addressId, connection, transaction, token), cancellationToken);
        }

        public async Task<CustomerAddressSnapshot?> GetOwnedAddressAsync(Guid customerId, Guid addressId,
            DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            ValidateIds(customerId, addressId);
            var address = await addresses.GetOwnedAsync(customerId, addressId, connection, transaction, cancellationToken);
            return address is null ? null : ToSnapshot(address);
        }

        private static CustomerAddressSnapshot ToSnapshot(CustomerAddress address)
            => new(address.Id, address.UserId, address.AddressText, address.Latitude,
                address.Longitude, address.ContactName, address.ContactPhone);

        private static void ValidateIds(Guid customerId, Guid addressId)
        {
            if (customerId == Guid.Empty) throw new ArgumentException("Customer ID is required.", nameof(customerId));
            if (addressId == Guid.Empty) throw new ArgumentException("Address ID is required.", nameof(addressId));
        }
    }
}

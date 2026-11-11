using System.Net.Mail;
using System.Text.RegularExpressions;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Application.Models;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class CustomerSelfService(ITransactionRunner transactions, IUserRepository users,
        ICustomerAddressRepository addresses) : ICustomerSelfService
    {
        public Task<CustomerProfile?> GetProfileAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            ValidateUserId(userId);
            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                var user = await users.GetByIdAsync(userId, connection, transaction, token);
                return user is { IsActive: true, DeleteDate: null } ? new CustomerProfile(user.Id, user.Email) : null;
            }, cancellationToken);
        }

        public Task<CustomerProfile?> UpdateProfileAsync(Guid userId, string email, CancellationToken cancellationToken = default)
        {
            ValidateUserId(userId);
            email = ValidateEmail(email);
            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                var user = await users.GetByIdAsync(userId, connection, transaction, token);
                if (user is not { IsActive: true, DeleteDate: null }) return null;
                await users.SetOwnEmailAsync(userId, email, connection, transaction, token);
                return new CustomerProfile(userId, email);
            }, cancellationToken);
        }

        public Task<IReadOnlyList<CustomerAddress>> GetAddressesAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            ValidateUserId(userId);
            return transactions.ExecuteAsync((connection, transaction, token) =>
                addresses.GetOwnedListAsync(userId, connection, transaction, token), cancellationToken);
        }

        public Task<CustomerAddressPage> GetAddressPageAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken = default)
        {
            ValidateUserId(userId);
            if (page < 1 || pageSize is < 1 or > 100)
                throw new ArgumentException("Page must be positive and pageSize must be 1 to 100.", nameof(page));
            return transactions.ExecuteAsync((connection, transaction, token) =>
                addresses.GetOwnedPageAsync(userId, page, pageSize, connection, transaction, token), cancellationToken);
        }

        public Task<CustomerAddress?> GetAddressAsync(Guid userId, Guid addressId, CancellationToken cancellationToken = default)
        {
            ValidateIds(userId, addressId);
            return transactions.ExecuteAsync((connection, transaction, token) =>
                addresses.GetOwnedAsync(userId, addressId, connection, transaction, token), cancellationToken);
        }

        public Task<Guid> CreateAddressAsync(Guid userId, CustomerAddressInput input, CancellationToken cancellationToken = default)
        {
            ValidateUserId(userId);
            var address = ToAddress(input);
            return transactions.ExecuteAsync((connection, transaction, token) =>
                addresses.InsertAsync(userId, address, connection, transaction, token), cancellationToken);
        }

        public Task<bool> UpdateAddressAsync(Guid userId, Guid addressId, CustomerAddressInput input,
            CancellationToken cancellationToken = default)
        {
            ValidateIds(userId, addressId);
            var address = ToAddress(input);
            address.Id = addressId;
            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                if (await addresses.GetOwnedAsync(userId, addressId, connection, transaction, token) is null)
                    return false;
                await addresses.UpdateOwnedAsync(userId, address, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public Task<bool> DeleteAddressAsync(Guid userId, Guid addressId, CancellationToken cancellationToken = default)
        {
            ValidateIds(userId, addressId);
            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                if (await addresses.GetOwnedAsync(userId, addressId, connection, transaction, token) is null)
                    return false;
                await addresses.DeleteOwnedAsync(userId, addressId, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        private static CustomerAddress ToAddress(CustomerAddressInput input)
        {
            ArgumentNullException.ThrowIfNull(input);
            return new CustomerAddress
            {
                Label = ValidateText(input.Label, 100, nameof(input.Label)),
                AddressText = ValidateText(input.AddressText, 2000, nameof(input.AddressText)),
                ContactName = ValidateText(input.ContactName, 200, nameof(input.ContactName)),
                ContactPhone = ValidatePhone(input.ContactPhone),
                Latitude = ValidateCoordinate(input.Latitude, -90, 90, nameof(input.Latitude)),
                Longitude = ValidateCoordinate(input.Longitude, -180, 180, nameof(input.Longitude)),
                IsActive = true
            };
        }

        private static string ValidateText(string? value, int maxLength, string name)
        {
            if (string.IsNullOrWhiteSpace(value) || value.Trim().Length > maxLength)
                throw new ArgumentException($"{name} is required and must not exceed {maxLength} characters.", name);
            return value.Trim();
        }

        private static decimal ValidateCoordinate(decimal value, decimal min, decimal max, string name)
        {
            if (value < min || value > max || decimal.Round(value, 6) != value)
                throw new ArgumentException($"{name} is outside its permitted range or precision.", name);
            return value;
        }

        private static string ValidatePhone(string? phone)
        {
            var value = phone?.Trim();
            if (value is null || !Regex.IsMatch(value, @"^\+?[0-9]{7,15}$", RegexOptions.CultureInvariant))
                throw new ArgumentException("ContactPhone must contain 7 to 15 digits with an optional leading +.", nameof(CustomerAddressInput.ContactPhone));
            return value;
        }

        private static string ValidateEmail(string? email)
        {
            if (string.IsNullOrWhiteSpace(email) || email.Trim().Length < 4 || email.Length > 320 ||
                !MailAddress.TryCreate(email.Trim(), out var parsed) || parsed.Address != email.Trim())
                throw new ArgumentException("A valid email address is required.", nameof(email));
            return email.Trim();
        }

        private static void ValidateUserId(Guid userId)
        {
            if (userId == Guid.Empty) throw new ArgumentException("User ID is required.", nameof(userId));
        }

        private static void ValidateIds(Guid userId, Guid addressId)
        {
            ValidateUserId(userId);
            if (addressId == Guid.Empty) throw new ArgumentException("Address ID is required.", nameof(addressId));
        }
    }
}

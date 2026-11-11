using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Ordering.Application.Contracts;
using GiysiGo.Modules.Ordering.Domain;

namespace GiysiGo.Modules.Ordering.Application
{
    public sealed class CartCommandService(
        ITransactionRunner transactionRunner,
        ICartCommandRepository cartRepository,
        IOrderWorkflowRepository workflowRepository,
        ICustomerAddressReader addressReader,
        IStoreCatalogReader catalogReader,
        ITransactionalStoreCatalogReader transactionalCatalogReader,
        ICurrentUser currentUser) : ICartCommandService
    {
        public async Task<Guid> CreateAsync(Guid storeId, Guid addressId, DateTime? pickupStartUtc, DateTime? pickupEndUtc, CancellationToken cancellationToken = default)
        {
            ValidatePickupWindow(pickupStartUtc, pickupEndUtc);
            if (storeId == Guid.Empty || addressId == Guid.Empty)
                throw new ArgumentException("Store and address IDs are required.");
            var customerId = RequireCurrentUserId();
            var address = await addressReader.GetOwnedAddressAsync(customerId, addressId, cancellationToken)
                ?? throw new UnauthorizedAccessException("Address is not owned by the customer.");
            if (await catalogReader.GetStoreLocationAsync(storeId, cancellationToken) is null
                || !await catalogReader.ServesLocationAsync(storeId, address.Latitude, address.Longitude, cancellationToken))
                throw new InvalidOperationException("Store is unavailable for the selected address.");
            var cart = new Cart
            {
                Id = Guid.NewGuid(), CustomerId = customerId, StoreId = storeId, AddressId = addressId,
                PickupWindowStart = pickupStartUtc, PickupWindowEnd = pickupEndUtc, Status = "OPEN", Version = 0
            };
            return await transactionRunner.ExecuteAsync((connection, transaction, token) =>
                cartRepository.CreateAsync(cart, connection, transaction, token), cancellationToken);
        }

        public async Task AddItemAsync(CartItem item, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(item);
            if (item.Id == Guid.Empty || item.CartId == Guid.Empty || item.ProductTypeId == Guid.Empty)
                throw new ArgumentException("Cart item, cart, and product type IDs are required.", nameof(item));
            if (item.CustomerMeasurement is <= 0)
                throw new ArgumentOutOfRangeException(nameof(item), "Customer measurement must be positive when provided.");
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                await cartRepository.AddItemAsync(item, customerId, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public async Task AddServiceAsync(CartItemService service, Guid serviceId, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(service);
            if (service.Id == Guid.Empty || service.CartItemId == Guid.Empty || service.StoreOfferingId == Guid.Empty || serviceId == Guid.Empty)
                throw new ArgumentException("Cart item service, cart item, offering, and service IDs are required.", nameof(service));
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                var context = await cartRepository.GetCartItemCatalogContextAsync(service.CartItemId, customerId, expectedCartVersion, connection, transaction, token)
                    ?? throw new InvalidOperationException("Open cart item was not found for the customer or its version is stale.");
                var offering = await transactionalCatalogReader.GetOfferingByIdAsync(
                    context.StoreId, context.ProductTypeId, service.StoreOfferingId, connection, transaction, token);
                if (offering is null || !offering.IsActive || offering.ServiceId != serviceId
                    || offering.StoreId != context.StoreId || offering.ProductTypeId != context.ProductTypeId
                    || offering.StoreOfferingId != service.StoreOfferingId)
                    throw new InvalidOperationException("Selected offering is unavailable for this product and store.");
                if (offering.SelectionKind is not ("BASE" or "ALTERNATIVE" or "ADD_ON"))
                    throw new InvalidOperationException("Selected offering has an unsupported selection kind.");
                await cartRepository.AddServiceAsync(service, serviceId, customerId, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public async Task RemoveServiceAsync(Guid cartId, Guid cartItemId, Guid serviceId, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            ValidateCartItemAndChildIds(cartId, cartItemId, serviceId);
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                await cartRepository.RemoveServiceAsync(cartId, cartItemId, serviceId, customerId, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public async Task AddPhotoAsync(CartItemPhoto photo, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(photo);
            if (photo.Id == Guid.Empty || photo.CartItemId == Guid.Empty)
                throw new ArgumentException("Photo and cart item IDs are required.", nameof(photo));
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            if (string.IsNullOrWhiteSpace(photo.StorageKey) || photo.StorageKey.Length > 1024)
                throw new ArgumentException("Photo storage key must contain 1 to 1024 characters.", nameof(photo));
            if (string.IsNullOrWhiteSpace(photo.PhotoType) || photo.PhotoType.Length > 40)
                throw new ArgumentException("Photo type must contain 1 to 40 characters.", nameof(photo));
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                await cartRepository.AddPhotoAsync(photo, customerId, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public async Task RemovePhotoAsync(Guid cartId, Guid cartItemId, Guid photoId, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            ValidateCartItemAndChildIds(cartId, cartItemId, photoId);
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                await cartRepository.RemovePhotoAsync(cartId, cartItemId, photoId, customerId, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public async Task RemoveItemAsync(Guid cartId, Guid itemId, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            if (cartId == Guid.Empty || itemId == Guid.Empty)
                throw new ArgumentException("Cart and item IDs are required.");
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                await cartRepository.RemoveItemAsync(cartId, itemId, customerId, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        public async Task SetAddressAndPickupWindowAsync(Guid cartId, Guid addressId, DateTime? pickupStartUtc, DateTime? pickupEndUtc, int expectedCartVersion, CancellationToken cancellationToken = default)
        {
            ValidatePickupWindow(pickupStartUtc, pickupEndUtc);
            if (cartId == Guid.Empty || addressId == Guid.Empty)
                throw new ArgumentException("Cart and address IDs are required.");
            ValidateExpectedCartVersion(expectedCartVersion);
            var customerId = RequireCurrentUserId();
            await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                var storeId = await workflowRepository.GetOpenCartStoreIdAsync(cartId, customerId, connection, transaction, token)
                    ?? throw new InvalidOperationException("Open cart was not found for the customer.");
                var address = await addressReader.GetOwnedAddressAsync(customerId, addressId, token)
                    ?? throw new UnauthorizedAccessException("Address is not owned by the customer.");
                if (!await transactionalCatalogReader.ServesLocationAsync(storeId, address.Latitude, address.Longitude, connection, transaction, token))
                    throw new InvalidOperationException("Store does not serve the selected address.");
                await cartRepository.SetAddressAndPickupWindowAsync(cartId, customerId, addressId, pickupStartUtc, pickupEndUtc, expectedCartVersion, connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        private Guid RequireCurrentUserId() => currentUser.IsAuthenticated && currentUser.UserId is Guid userId
            ? userId
            : throw new UnauthorizedAccessException("An authenticated user is required for this operation.");

        private static void ValidateExpectedCartVersion(int version)
        {
            if (version < 0)
                throw new ArgumentOutOfRangeException(nameof(version), "Cart version cannot be negative.");
        }

        private static void ValidateCartItemAndChildIds(Guid cartId, Guid cartItemId, Guid childId)
        {
            if (cartId == Guid.Empty || cartItemId == Guid.Empty || childId == Guid.Empty)
                throw new ArgumentException("Cart, cart item, and child IDs are required.");
        }

        private static void ValidatePickupWindow(DateTime? startUtc, DateTime? endUtc)
        {
            if (startUtc.HasValue != endUtc.HasValue)
                throw new ArgumentException("Pickup window start and end must both be provided or both be omitted.");
            if (startUtc is not null && (startUtc.Value.Kind != DateTimeKind.Utc || endUtc!.Value.Kind != DateTimeKind.Utc || endUtc <= startUtc))
                throw new ArgumentException("Pickup window must be a valid UTC interval.");
        }
    }
}

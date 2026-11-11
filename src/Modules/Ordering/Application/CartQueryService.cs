using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Ordering.Application.Contracts;

namespace GiysiGo.Modules.Ordering.Application
{
    public sealed class CartQueryService(
        ITransactionRunner transactionRunner,
        ICartQueryRepository cartRepository,
        ITransactionalStoreCatalogReader catalogReader,
        ICurrentUser currentUser) : ICartQueryService
    {
        public Task<CartReadModel?> GetOpenCartAsync(Guid cartId, CancellationToken cancellationToken = default)
        {
            if (!currentUser.IsAuthenticated || currentUser.UserId is not Guid customerId)
                throw new UnauthorizedAccessException("An authenticated user is required for this operation.");
            if (cartId == Guid.Empty)
                throw new ArgumentException("Cart ID is required.", nameof(cartId));
            return transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
            {
                var cart = await cartRepository.GetOpenCartAsync(cartId, customerId, connection, transaction, token);
                if (cart is null)
                    return null;

                var pricedItems = new List<CartItemReadModel>(cart.Items.Count);
                foreach (var item in cart.Items)
                {
                    var offerings = new List<StoreOfferingSnapshot>(item.Services.Count);
                    foreach (var selected in item.Services)
                    {
                        var offering = await catalogReader.GetOfferingByIdAsync(
                            cart.Cart.StoreId, item.Item.ProductTypeId, selected.StoreOfferingId, connection, transaction, token);
                        if (offering is null || !offering.IsActive || offering.StoreOfferingId != selected.StoreOfferingId)
                            throw new InvalidOperationException("A selected offering is no longer active for this cart item.");
                        offerings.Add(offering);
                    }
                    var estimate = CartEstimateCalculator.Calculate(
                        cart.Cart.StoreId, item.Item.ProductTypeId, item.Item.CustomerMeasurement, offerings, item.Item.Id);
                    pricedItems.Add(item with { Estimate = estimate });
                }

                var allLines = pricedItems.SelectMany(item => item.Estimate.Lines).ToArray();
                var isComplete = pricedItems.Count > 0 && pricedItems.All(item => item.Estimate.IsComplete);
                decimal? total = isComplete
                    ? decimal.Round(pricedItems.Sum(item => item.Estimate.Total ?? 0m), 2, MidpointRounding.AwayFromZero)
                    : null;
                return new CartReadModel(cart.Cart, pricedItems, new CartEstimateResult(allLines, total, "TRY", true, isComplete));
            }, cancellationToken);
        }
    }
}

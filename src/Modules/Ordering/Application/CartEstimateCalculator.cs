using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Ordering.Application.Contracts;

namespace GiysiGo.Modules.Ordering.Application
{
    public static class CartEstimateCalculator
    {
        public static CartEstimateResult Calculate(
            Guid storeId,
            Guid productTypeId,
            decimal? customerMeasurement,
            IReadOnlyCollection<StoreOfferingSnapshot> offerings,
            Guid cartItemId = default)
        {
            ArgumentNullException.ThrowIfNull(offerings);
            if (storeId == Guid.Empty || productTypeId == Guid.Empty)
                throw new ArgumentException("Store and product type IDs are required.");
            if (customerMeasurement is <= 0)
                throw new ArgumentOutOfRangeException(nameof(customerMeasurement), "Customer measurement must be positive when provided.");

            var primarySelections = offerings.Count(offering => offering.SelectionKind is "BASE" or "ALTERNATIVE");
            if (primarySelections > 1)
                throw new InvalidOperationException("Only one BASE or ALTERNATIVE service may be selected per physical item.");

            var lines = new List<CartEstimateLine>(offerings.Count);
            var requiresMeasurement = false;
            foreach (var offering in offerings)
            {
                if (!offering.IsActive || offering.StoreId != storeId || offering.ProductTypeId != productTypeId)
                    throw new InvalidOperationException("An inactive or mismatched offering cannot be estimated.");
                if (offering.UnitPrice < 0)
                    throw new InvalidOperationException("Offering unit price cannot be negative.");

                var priceUnit = offering.PriceUnit.Trim().ToUpperInvariant();
                var quantity = priceUnit switch
                {
                    "PIECE" => 1m,
                    "M2" => customerMeasurement,
                    _ => throw new InvalidOperationException($"Unsupported price unit '{offering.PriceUnit}'.")
                };
                if (priceUnit == "M2" && quantity is null)
                    requiresMeasurement = true;
                decimal? amount = quantity is null ? null : decimal.Round(offering.UnitPrice * quantity.Value, 2, MidpointRounding.AwayFromZero);
                lines.Add(new CartEstimateLine(cartItemId, offering.ServiceId, offering.UnitPrice, priceUnit, quantity, amount));
            }

            var isComplete = primarySelections == 1 && !requiresMeasurement;
            decimal? total = isComplete ? decimal.Round(lines.Sum(line => line.Amount ?? 0m), 2, MidpointRounding.AwayFromZero) : null;
            return new CartEstimateResult(lines, total, "TRY", true, isComplete);
        }
    }
}

using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Ordering.Application;

namespace GiysiGo.Modules.Ordering.Tests
{
    public sealed class CartEstimateCalculatorTests
    {
        [Fact]
        public void Calculates_piece_and_square_meter_lines_and_rounds_each_line_to_try_cents()
        {
            var storeId = Guid.NewGuid();
            var productTypeId = Guid.NewGuid();
            var pieceServiceId = Guid.NewGuid();
            var areaServiceId = Guid.NewGuid();
            StoreOfferingSnapshot[] offerings =
            [
                new(storeId, productTypeId, pieceServiceId, 12.34m, "PIECE", true) { SelectionKind = "BASE" },
                new(storeId, productTypeId, areaServiceId, 6.67m, "M2", true) { SelectionKind = "ADD_ON" }
            ];

            var estimate = CartEstimateCalculator.Calculate(storeId, productTypeId, 1.5m, offerings);

            Assert.True(estimate.IsEstimate);
            Assert.Equal("TRY", estimate.Currency);
            Assert.Equal(1m, estimate.Lines[0].Quantity);
            Assert.Equal(12.34m, estimate.Lines[0].Amount);
            Assert.Equal(1.5m, estimate.Lines[1].Quantity);
            Assert.Equal(10.01m, estimate.Lines[1].Amount);
            Assert.Equal(22.35m, estimate.Total);
        }

        [Fact]
        public void Marks_estimate_incomplete_when_square_meter_measurement_is_missing()
        {
            var offering = new StoreOfferingSnapshot(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), 10m, "M2", true) { SelectionKind = "BASE" };

            var estimate = CartEstimateCalculator.Calculate(offering.StoreId, offering.ProductTypeId, null, [offering]);

            Assert.False(estimate.IsComplete);
            Assert.Null(estimate.Total);
            Assert.Null(estimate.Lines[0].Amount);
        }

        [Fact]
        public void Add_on_alone_and_multiple_primary_services_do_not_complete_an_estimate()
        {
            var storeId = Guid.NewGuid();
            var productTypeId = Guid.NewGuid();
            var addOn = new StoreOfferingSnapshot(storeId, productTypeId, Guid.NewGuid(), 3m, "PIECE", true) { SelectionKind = "ADD_ON" };
            var baseService = new StoreOfferingSnapshot(storeId, productTypeId, Guid.NewGuid(), 10m, "PIECE", true) { SelectionKind = "BASE" };
            var alternative = new StoreOfferingSnapshot(storeId, productTypeId, Guid.NewGuid(), 12m, "PIECE", true) { SelectionKind = "ALTERNATIVE" };

            Assert.False(CartEstimateCalculator.Calculate(storeId, productTypeId, null, [addOn]).IsComplete);
            Assert.Throws<InvalidOperationException>(() => CartEstimateCalculator.Calculate(storeId, productTypeId, null, [baseService, alternative]));
        }

        [Fact]
        public void Rejects_inactive_or_cross_store_offerings()
        {
            var offering = new StoreOfferingSnapshot(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), 10m, "PIECE", false);

            Assert.Throws<InvalidOperationException>(() => CartEstimateCalculator.Calculate(
                offering.StoreId, offering.ProductTypeId, null, [offering]));
        }
    }
}

using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Ordering.IntegrationEvents
{
    public sealed record OrderPlacedEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId, Guid StoreId, DateTime PickupWindowStartUtc, DateTime PickupWindowEndUtc) : IIntegrationEvent
    {
        public string EventType => "ordering.order_placed.v1";
    }
}

using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Ordering.IntegrationEvents
{
    public sealed record OrderReadyForDeliveryEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId) : IIntegrationEvent
    {
        public string EventType => "ordering.order_ready_for_delivery.v1";
    }
}

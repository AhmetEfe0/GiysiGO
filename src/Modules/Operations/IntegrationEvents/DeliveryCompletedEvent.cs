using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Operations.IntegrationEvents
{
    public sealed record DeliveryCompletedEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId, Guid TaskId) : IIntegrationEvent
    {
        public string EventType => "operations.delivery_completed.v1";
    }
}

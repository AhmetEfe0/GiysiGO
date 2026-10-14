using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Operations.IntegrationEvents
{
    public sealed record PickupAtStoreEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId) : IIntegrationEvent
    {
        public string EventType => "operations.pickup_at_store.v1";
    }
}

using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Operations.IntegrationEvents
{
    public sealed record AllItemsInspectedEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId) : IIntegrationEvent
    {
        public string EventType => "operations.all_items_inspected.v1";
    }
}

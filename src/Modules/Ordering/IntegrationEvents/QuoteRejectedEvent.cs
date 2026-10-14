using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Ordering.IntegrationEvents
{
    public sealed record QuoteRejectedEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId, Guid QuoteId) : IIntegrationEvent
    {
        public string EventType => "ordering.quote_rejected.v1";
    }
}

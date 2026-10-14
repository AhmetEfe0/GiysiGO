using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Ordering.IntegrationEvents
{
    public sealed record PaymentSucceededEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId, Guid QuoteId) : IIntegrationEvent
    {
        public string EventType => "ordering.payment_succeeded.v1";
    }
}

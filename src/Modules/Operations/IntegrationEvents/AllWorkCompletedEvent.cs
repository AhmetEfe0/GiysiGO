using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.Modules.Operations.IntegrationEvents
{
    public sealed record AllWorkCompletedEvent(Guid EventId, DateTime OccurredAtUtc, Guid OrderId) : IIntegrationEvent
    {
        public string EventType => "operations.all_work_completed.v1";
    }
}

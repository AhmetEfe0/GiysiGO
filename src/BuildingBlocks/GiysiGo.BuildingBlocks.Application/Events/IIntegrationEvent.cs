namespace GiysiGo.BuildingBlocks.Application.Events
{
    public interface IIntegrationEvent
    {
        Guid EventId { get; }
        DateTime OccurredAtUtc { get; }
        string EventType { get; }
    }
}

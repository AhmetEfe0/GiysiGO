namespace GiysiGo.BuildingBlocks.Infrastructure
{
    internal sealed class OutboxMessage
    {
        public Guid Id { get; set; }
        public string EventType { get; set; } = string.Empty;
        public string Payload { get; set; } = string.Empty;
    }
}

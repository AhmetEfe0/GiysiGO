using System.Data.Common;
using System.Text.Json;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Events;

namespace GiysiGo.BuildingBlocks.Infrastructure
{
    public sealed class SqlOutboxWriter : IOutboxWriter
    {
        public async Task WriteAsync(IIntegrationEvent integrationEvent, Guid aggregateId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            const string sql = """
                INSERT INTO [building_blocks].[outbox_messages]
                    (id, event_type, aggregate_id, payload, create_date)
                VALUES
                    (@Id, @EventType, @AggregateId, @Payload, @CreateDate);
                """;

            await connection.ExecuteAsync(new CommandDefinition(sql, new
            {
                Id = integrationEvent.EventId,
                integrationEvent.EventType,
                AggregateId = aggregateId,
                Payload = JsonSerializer.Serialize(integrationEvent, integrationEvent.GetType()),
                CreateDate = integrationEvent.OccurredAtUtc
            }, transaction, cancellationToken: cancellationToken));
        }
    }
}

using System.Data;
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
            await connection.ExecuteAsync(new CommandDefinition("[building_blocks].[spInsertOutboxMessage]", new
            {
                Id = integrationEvent.EventId,
                integrationEvent.EventType,
                AggregateId = aggregateId,
                Payload = JsonSerializer.Serialize(integrationEvent, integrationEvent.GetType()),
                CreateDate = integrationEvent.OccurredAtUtc
            }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }
    }
}

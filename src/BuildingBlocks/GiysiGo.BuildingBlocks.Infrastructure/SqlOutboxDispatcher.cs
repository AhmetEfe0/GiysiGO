using Dapper;
using GiysiGo.BuildingBlocks.Application.Events;
using GiysiGo.BuildingBlocks.Application.Transactions;

namespace GiysiGo.BuildingBlocks.Infrastructure
{
    public sealed class SqlOutboxDispatcher(
        ITransactionRunner transactionRunner,
        SqlConnectionFactory connectionFactory,
        IEnumerable<IOutboxEventHandler> handlers) : IOutboxDispatcher
    {
        public async Task<bool> DispatchNextAsync(CancellationToken cancellationToken = default)
        {
            Guid? messageId = null;
            try
            {
                return await transactionRunner.ExecuteAsync(async (connection, transaction, token) =>
                {
                    const string selectSql = """
                        SELECT TOP (1) id AS Id, event_type AS EventType, payload AS Payload
                        FROM [building_blocks].[outbox_messages] WITH (UPDLOCK, READPAST, ROWLOCK)
                        WHERE processed_at IS NULL AND delete_date IS NULL
                        ORDER BY create_date, id;
                        """;

                    var message = await connection.QuerySingleOrDefaultAsync<OutboxMessage>(
                        new CommandDefinition(selectSql, transaction: transaction, cancellationToken: token));

                    if (message is null)
                    {
                        return false;
                    }

                    messageId = message.Id;
                    var consumers = handlers.Where(handler => handler.EventType == message.EventType).ToArray();
                    if (consumers.Length == 0)
                    {
                        throw new InvalidOperationException($"No outbox handler is registered for {message.EventType}.");
                    }

                    foreach (var consumer in consumers)
                    {
                        await consumer.HandleAsync(message.Payload, connection, transaction, token);
                    }

                    const string updateSql = """
                        UPDATE [building_blocks].[outbox_messages]
                        SET processed_at = SYSUTCDATETIME(), update_date = SYSUTCDATETIME(),
                            attempt_count = attempt_count + 1, last_error = NULL
                        WHERE id = @Id AND processed_at IS NULL;
                        """;

                    var changed = await connection.ExecuteAsync(new CommandDefinition(
                        updateSql, new { message.Id }, transaction, cancellationToken: token));

                    if (changed != 1)
                    {
                        throw new InvalidOperationException($"Outbox message {message.Id} was not marked processed.");
                    }

                    return true;
                }, cancellationToken);
            }
            catch (Exception exception) when (messageId.HasValue && !cancellationToken.IsCancellationRequested)
            {
                await using var connection = await connectionFactory.OpenAsync(cancellationToken);
                const string failureSql = """
                    UPDATE [building_blocks].[outbox_messages]
                    SET attempt_count = attempt_count + 1, last_error = @Error,
                        update_date = SYSUTCDATETIME()
                    WHERE id = @Id AND processed_at IS NULL;
                    """;
                await connection.ExecuteAsync(new CommandDefinition(
                    failureSql, new { Id = messageId.Value, Error = exception.Message },
                    cancellationToken: cancellationToken));
                throw;
            }
        }
    }
}

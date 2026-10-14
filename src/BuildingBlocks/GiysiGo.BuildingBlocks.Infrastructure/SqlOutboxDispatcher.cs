using System.Data;
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
                    var message = await connection.QuerySingleOrDefaultAsync<OutboxMessage>(
                        new CommandDefinition("[building_blocks].[spGetNextOutboxMessage]",
                            transaction: transaction, commandType: CommandType.StoredProcedure,
                            cancellationToken: token));

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

                    await connection.ExecuteAsync(new CommandDefinition(
                        "[building_blocks].[spMarkOutboxMessageProcessed]", new { message.Id }, transaction,
                        commandType: CommandType.StoredProcedure, cancellationToken: token));

                    return true;
                }, cancellationToken);
            }
            catch (Exception exception) when (messageId.HasValue && !cancellationToken.IsCancellationRequested)
            {
                await using var connection = await connectionFactory.OpenAsync(cancellationToken);
                await connection.ExecuteAsync(new CommandDefinition(
                    "[building_blocks].[spRecordOutboxMessageFailure]",
                    new { Id = messageId.Value, Error = exception.Message },
                    commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
                throw;
            }
        }
    }
}

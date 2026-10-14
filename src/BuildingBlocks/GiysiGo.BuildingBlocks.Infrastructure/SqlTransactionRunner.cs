using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Transactions;

namespace GiysiGo.BuildingBlocks.Infrastructure
{
    public sealed class SqlTransactionRunner(SqlConnectionFactory connectionFactory) : ITransactionRunner
    {
        public async Task<TResult> ExecuteAsync<TResult>(Func<DbConnection, DbTransaction, CancellationToken, Task<TResult>> action, CancellationToken cancellationToken = default)
        {
            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            await using var transaction = await connection.BeginTransactionAsync(cancellationToken);
            var result = await action(connection, transaction, cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return result;
        }
    }
}

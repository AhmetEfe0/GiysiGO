using System.Data;
using System.Data.Common;

namespace GiysiGo.BuildingBlocks.Application.Transactions
{
    public interface ITransactionRunner
    {
        Task<TResult> ExecuteAsync<TResult>(Func<DbConnection, DbTransaction, CancellationToken, Task<TResult>> action, CancellationToken cancellationToken = default);
        Task<TResult> ExecuteAsync<TResult>(Func<DbConnection, DbTransaction, CancellationToken, Task<TResult>> action, IsolationLevel isolationLevel, CancellationToken cancellationToken = default);
    }
}

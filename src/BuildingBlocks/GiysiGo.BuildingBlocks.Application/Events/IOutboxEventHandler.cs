using System.Data.Common;

namespace GiysiGo.BuildingBlocks.Application.Events
{
    public interface IOutboxEventHandler
    {
        string EventType { get; }
        Task HandleAsync(string payload, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
    }
}

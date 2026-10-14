using System.Data.Common;

namespace GiysiGo.BuildingBlocks.Application.Events
{
    public interface IOutboxWriter
    {
        Task WriteAsync(IIntegrationEvent integrationEvent, Guid aggregateId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
    }
}

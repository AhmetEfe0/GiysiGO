namespace GiysiGo.BuildingBlocks.Application.Events
{
    public interface IOutboxDispatcher
    {
        Task<bool> DispatchNextAsync(CancellationToken cancellationToken = default);
    }
}

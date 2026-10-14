namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface IOrderPickupReader
    {
        Task<OrderPickupSnapshot?> GetPickupAsync(Guid orderId, CancellationToken cancellationToken = default);
    }
}

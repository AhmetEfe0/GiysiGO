namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public interface ICartQueryService
    {
        Task<CartReadModel?> GetOpenCartAsync(Guid cartId, CancellationToken cancellationToken = default);
    }
}

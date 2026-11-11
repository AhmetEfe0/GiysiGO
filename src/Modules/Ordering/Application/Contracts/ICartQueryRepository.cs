using System.Data.Common;

namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public interface ICartQueryRepository
    {
        Task<CartReadModel?> GetOpenCartAsync(Guid cartId, Guid customerId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
    }
}

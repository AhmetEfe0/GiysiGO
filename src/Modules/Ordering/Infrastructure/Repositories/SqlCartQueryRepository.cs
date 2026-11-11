using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.Modules.Ordering.Application.Contracts;
using GiysiGo.Modules.Ordering.Domain;

namespace GiysiGo.Modules.Ordering.Infrastructure.Repositories
{
    public sealed class SqlCartQueryRepository : ICartQueryRepository
    {
        public async Task<CartReadModel?> GetOpenCartAsync(Guid cartId, Guid customerId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            using var results = await connection.QueryMultipleAsync(new CommandDefinition(
                "[ordering].[spGetOpenCart]", new { CartId = cartId, CustomerId = customerId }, transaction,
                commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));

            var cart = await results.ReadSingleOrDefaultAsync<Cart>();
            if (cart is null)
                return null;

            var items = (await results.ReadAsync<CartItem>()).ToArray();
            var services = await results.ReadAsync<CartItemService>();
            var photos = await results.ReadAsync<CartItemPhoto>();
            var itemModels = items.Select(item => new CartItemReadModel(
                item,
                services.Where(service => service.CartItemId == item.Id).ToArray(),
                photos.Where(photo => photo.CartItemId == item.Id).ToArray(),
                new CartEstimateResult([], null, "TRY", true, false))).ToArray();
            return new CartReadModel(cart, itemModels, new CartEstimateResult([], null, "TRY", true, false));
        }
    }
}

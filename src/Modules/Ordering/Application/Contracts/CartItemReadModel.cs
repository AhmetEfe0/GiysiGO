using GiysiGo.Modules.Ordering.Domain;

namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record CartItemReadModel(
        CartItem Item,
        IReadOnlyList<CartItemService> Services,
        IReadOnlyList<CartItemPhoto> Photos,
        CartEstimateResult Estimate);
}

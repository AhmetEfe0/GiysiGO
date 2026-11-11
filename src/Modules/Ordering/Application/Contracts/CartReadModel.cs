using GiysiGo.Modules.Ordering.Domain;

namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record CartReadModel(Cart Cart, IReadOnlyList<CartItemReadModel> Items, CartEstimateResult Estimate);
}

namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record OrderTransitionResult(Guid OrderId, Guid StoreId, string Status, bool Changed);
}

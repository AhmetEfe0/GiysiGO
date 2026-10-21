namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record QuoteDecisionResult(Guid OrderId, Guid QuoteId, bool Accepted, bool Changed);
}

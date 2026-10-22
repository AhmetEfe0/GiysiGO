namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public sealed record PaymentCompletionResult(Guid OrderId, Guid QuoteId, bool Succeeded, bool Changed);
}

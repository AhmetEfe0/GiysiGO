namespace GiysiGo.Modules.Identity.Application.Models
{
    public sealed record StaffScopeAccess(string Scope, Guid? CorporateId, Guid? StoreId, string? CorporateName,
        IReadOnlyList<string> Roles, IReadOnlyList<string> Permissions);
}

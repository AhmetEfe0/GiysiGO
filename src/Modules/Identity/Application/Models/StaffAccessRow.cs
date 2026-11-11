namespace GiysiGo.Modules.Identity.Application.Models
{
    public sealed record StaffAccessRow(Guid? CorporateId, Guid? StoreId, string? CorporateName,
        Guid RoleId, string RoleCode, string? PermissionCode);
}

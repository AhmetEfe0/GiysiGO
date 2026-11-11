namespace GiysiGo.Modules.Identity.Application.Models
{
    public sealed record StaffMemberPage(IReadOnlyList<StaffMember> Items, int Page, int PageSize, long TotalCount);
}

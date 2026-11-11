using GiysiGo.Modules.Identity.Application.Models;

namespace GiysiGo.Modules.Identity.Application.Interfaces
{
    public interface IStaffManagementService
    {
        Task<Guid> CreateCorporateAsync(string name, CancellationToken token = default);
        Task SetCorporateActiveAsync(Guid id, bool isActive, CancellationToken token = default);
        Task ChangeAssignmentAsync(Guid corporateId, Guid? storeId, Guid userId, Guid roleId, bool grant, CancellationToken token = default);
        Task<StaffMemberPage> GetMembersAsync(Guid corporateId, Guid? storeId, int page, int pageSize, CancellationToken token = default);
        Task<IReadOnlyList<StaffScopeAccess>> GetMyAccessAsync(CancellationToken token = default);
    }
}

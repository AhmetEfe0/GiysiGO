using System.Data.Common;
using GiysiGo.Modules.Identity.Application.Models;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Application.Interfaces.Repositories
{
    public interface IStaffManagementRepository
    {
        Task<Guid> CreateCorporateAsync(string name, DbConnection connection, DbTransaction transaction, CancellationToken token);
        Task SetCorporateActiveAsync(Guid id, bool isActive, DbConnection connection, DbTransaction transaction, CancellationToken token);
        Task<Corporate?> GetCorporateAsync(Guid id, DbConnection connection, DbTransaction transaction, CancellationToken token);
        Task<StaffMemberPage> GetMembersAsync(Guid corporateId, Guid? storeId, int page, int pageSize,
            DbConnection connection, DbTransaction transaction, CancellationToken token);
        Task<IReadOnlyList<StaffAccessRow>> GetAccessAsync(Guid userId, DbConnection connection, DbTransaction transaction, CancellationToken token);
    }
}

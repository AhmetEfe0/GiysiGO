using System.Data.Common;
using Dapper;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Application.Models;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Infrastructure.Repositories
{
    public sealed class StaffManagementRepository : IdentityCommandRepositoryBase, IStaffManagementRepository
    {
        public Task<Guid> CreateCorporateAsync(string name, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => connection.QuerySingleAsync<Guid>(Procedure("[identity].[spInsertCorporate]",
                new { Id = (Guid?)null, Name = name, IsActive = true }, connection, transaction, token));

        public Task SetCorporateActiveAsync(Guid id, bool isActive, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => connection.ExecuteAsync(Procedure("[identity].[spSetCorporateActive]",
                new { Id = id, IsActive = isActive }, connection, transaction, token));

        public Task<Corporate?> GetCorporateAsync(Guid id, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => connection.QuerySingleOrDefaultAsync<Corporate>(Procedure("[identity].[spGetCorporateById]",
                new { Id = id }, connection, transaction, token));

        public async Task<StaffMemberPage> GetMembersAsync(Guid corporateId, Guid? storeId, int page, int pageSize,
            DbConnection connection, DbTransaction transaction, CancellationToken token)
        {
            using var result = await connection.QueryMultipleAsync(Procedure("[identity].[spGetStaffMembers]",
                new { CorporateId = corporateId, StoreId = storeId, Page = page, PageSize = pageSize }, connection, transaction, token));
            var total = await result.ReadSingleAsync<long>();
            var items = (await result.ReadAsync<StaffMember>()).AsList();
            return new StaffMemberPage(items, page, pageSize, total);
        }

        public async Task<IReadOnlyList<StaffAccessRow>> GetAccessAsync(Guid userId, DbConnection connection, DbTransaction transaction, CancellationToken token)
            => (await connection.QueryAsync<StaffAccessRow>(Procedure("[identity].[spGetMyAccess]",
                new { UserId = userId }, connection, transaction, token))).AsList();
    }
}

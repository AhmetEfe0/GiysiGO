using System.Data.Common;
using GiysiGo.BuildingBlocks.Application;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Application.Interfaces.Repositories
{
    public interface ICorporateRepository : IRepository<Corporate>
    {
        Task<bool> IsActiveAsync(Guid corporateId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default);
    }
}

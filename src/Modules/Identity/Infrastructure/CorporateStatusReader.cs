using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class CorporateStatusReader(ICorporateRepository corporates) : ICorporateStatusReader
    {
        public Task<bool> IsActiveAsync(Guid corporateId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => corporates.IsActiveAsync(corporateId, connection, transaction, cancellationToken);
    }
}

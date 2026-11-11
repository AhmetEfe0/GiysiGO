using System.Data.Common;

namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface ICorporateStatusReader
    {
        Task<bool> IsActiveAsync(Guid corporateId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
    }
}

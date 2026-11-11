using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Catalog.Tests.IntegrationTests
{
    // Calls Identity's real SQL contract without referencing its Infrastructure assembly.
    public sealed class ReaderCorporateStatus : ICorporateStatusReader
    {
        public Task<bool> IsActiveAsync(Guid corporateId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => connection.QuerySingleAsync<bool>(new CommandDefinition("identity.spIsCorporateActive", new { CorporateId = corporateId },
                transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
    }
}

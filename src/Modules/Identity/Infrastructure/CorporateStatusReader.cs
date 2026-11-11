using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class CorporateStatusReader : ICorporateStatusReader
    {
        public Task<bool> IsActiveAsync(Guid corporateId, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
        {
            if (corporateId == Guid.Empty) throw new ArgumentException("Şirket kimliği boş olamaz.", nameof(corporateId));
            ArgumentNullException.ThrowIfNull(connection);
            ArgumentNullException.ThrowIfNull(transaction);
            if (connection.State != ConnectionState.Open || !ReferenceEquals(transaction.Connection, connection))
                throw new ArgumentException("Açık bağlantı ve ona ait etkin transaction gereklidir.");
            return connection.QuerySingleAsync<bool>(new CommandDefinition("identity.spIsCorporateActive",
                new { CorporateId = corporateId }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }
    }
}

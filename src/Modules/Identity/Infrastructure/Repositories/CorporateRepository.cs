using System.Data;
using System.Data.Common;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Infrastructure.Repositories
{
    public sealed class CorporateRepository(SqlConnectionFactory connectionFactory) : RepositoryBase<Corporate>(connectionFactory), ICorporateRepository
    {
        public Task<bool> IsActiveAsync(Guid corporateId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default)
        {
            if (corporateId == Guid.Empty) throw new ArgumentException("Şirket kimliği boş olamaz.", nameof(corporateId));
            ArgumentNullException.ThrowIfNull(connection);
            ArgumentNullException.ThrowIfNull(transaction);
            if (connection.State != ConnectionState.Open || !ReferenceEquals(transaction.Connection, connection))
                throw new ArgumentException("Açık bağlantı ve ona ait etkin transaction gereklidir.");
            return connection.QuerySingleAsync<bool>(new CommandDefinition("identity.spIsCorporateActive",
                new { CorporateId = corporateId }, transaction, commandType: CommandType.StoredProcedure, cancellationToken: cancellationToken));
        }

        protected override string SpGetAll => "[identity].[spGetAllCorporates]";
        protected override string SpGetById => "[identity].[spGetCorporateById]";
        protected override string SpInsert => "[identity].[spInsertCorporate]";
        protected override string SpUpdate => "[identity].[spUpdateCorporate]";
        protected override string SpDelete => "[identity].[spDeleteCorporate]";

        protected override object InsertParameters(Corporate entity) => new
        {
            Id = entity.Id == Guid.Empty ? (Guid?)null : entity.Id,
            entity.Name,
            entity.IsActive
        };

        protected override object UpdateParameters(Corporate entity) => new
        {
            entity.Id,
            entity.Name,
            entity.IsActive
        };
    }
}

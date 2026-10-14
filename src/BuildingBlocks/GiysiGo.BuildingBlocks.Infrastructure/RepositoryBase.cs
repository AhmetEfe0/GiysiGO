using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Application;
using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.BuildingBlocks.Infrastructure
{
    public abstract class RepositoryBase<TEntity>(SqlConnectionFactory connectionFactory) : IRepository<TEntity> where TEntity : IEntityBase<Guid>
    {
        protected abstract string SpGetAll { get; }
        protected abstract string SpGetById { get; }
        protected abstract string SpInsert { get; }
        protected abstract string SpUpdate { get; }
        protected abstract string SpDelete { get; }

        protected abstract object InsertParameters(TEntity entity);
        protected abstract object UpdateParameters(TEntity entity);

        public async Task<IReadOnlyList<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
        {
            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            var rows = await connection.QueryAsync<TEntity>(
                new CommandDefinition(SpGetAll, commandType: CommandType.StoredProcedure,
                    cancellationToken: cancellationToken));
            return rows.AsList();
        }

        public async Task<TEntity?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            return await connection.QuerySingleOrDefaultAsync<TEntity>(
                new CommandDefinition(SpGetById, new { Id = id }, commandType: CommandType.StoredProcedure,
                    cancellationToken: cancellationToken));
        }

        public async Task<Guid> InsertAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            return await connection.QuerySingleAsync<Guid>(
                new CommandDefinition(SpInsert, InsertParameters(entity), commandType: CommandType.StoredProcedure,
                    cancellationToken: cancellationToken));
        }

        public async Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            await connection.ExecuteAsync(
                new CommandDefinition(SpUpdate, UpdateParameters(entity), commandType: CommandType.StoredProcedure,
                    cancellationToken: cancellationToken));
        }

        public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
        {
            await using var connection = await connectionFactory.OpenAsync(cancellationToken);
            await connection.ExecuteAsync(
                new CommandDefinition(SpDelete, new { Id = id }, commandType: CommandType.StoredProcedure,
                    cancellationToken: cancellationToken));
        }
    }
}

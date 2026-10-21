using System.Data.Common;
using Dapper;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;

namespace GiysiGo.Modules.Identity.Infrastructure.Repositories
{
    public sealed class AuthSessionRepository : IdentityCommandRepositoryBase, IAuthSessionRepository
    {
        public async Task CreateAsync(Guid id, Guid userId, byte[] tokenHash, DateTime expiresAtUtc, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => await connection.ExecuteAsync(Procedure("[identity].[spCreateAuthSession]", new { Id = id, UserId = userId, TokenHash = tokenHash, ExpiresAtUtc = expiresAtUtc }, connection, transaction, cancellationToken));

        public Task<Guid?> RotateAsync(byte[] oldTokenHash, Guid newId, byte[] newTokenHash, DateTime newExpiresAtUtc, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => connection.QuerySingleAsync<Guid?>(Procedure("[identity].[spRotateAuthSession]", new { OldTokenHash = oldTokenHash, NewId = newId, NewTokenHash = newTokenHash, NewExpiresAtUtc = newExpiresAtUtc }, connection, transaction, cancellationToken));

        public async Task RevokeAsync(byte[] tokenHash, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default)
            => await connection.ExecuteAsync(Procedure("[identity].[spRevokeAuthSession]", new { TokenHash = tokenHash }, connection, transaction, cancellationToken));
    }
}

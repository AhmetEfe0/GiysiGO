using System.Data.Common;

namespace GiysiGo.Modules.Identity.Application.Interfaces.Repositories
{
    public interface IAuthSessionRepository
    {
        Task CreateAsync(Guid id, Guid userId, byte[] tokenHash, DateTime expiresAtUtc, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
        Task<Guid?> RotateAsync(byte[] oldTokenHash, Guid newId, byte[] newTokenHash, DateTime newExpiresAtUtc, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
        Task RevokeAsync(byte[] tokenHash, DbConnection connection, DbTransaction transaction, CancellationToken cancellationToken = default);
    }
}

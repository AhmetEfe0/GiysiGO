using System.Net.Mail;
using System.Security.Cryptography;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;
using Microsoft.AspNetCore.Identity;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public sealed class AuthService(ITransactionRunner transactions, IUserRepository users,
        IAuthSessionRepository sessions, IIdentityAccessRepository access, IPasswordHasher<User> passwordHasher,
        IAccessTokenIssuer accessTokenIssuer) : IAuthService
    {
        private static readonly TimeSpan RefreshLifetime = TimeSpan.FromDays(30);

        public Task<Guid> RegisterAsync(string email, string password, CancellationToken cancellationToken = default)
        {
            email = ValidateEmail(email);
            ValidatePassword(password);
            var user = new User { Email = email };
            user.PasswordHash = passwordHasher.HashPassword(user, password);
            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                var userId = await users.InsertAsync(user, connection, transaction, token);
                await access.GrantCustomerRoleAsync(userId, connection, transaction, token);
                return userId;
            }, cancellationToken);
        }

        public async Task<AuthTokenResult?> LoginAsync(string email, string password, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrEmpty(password) || email.Length > 320)
                return null;

            var refreshToken = CreateRefreshToken();
            var tokenHash = HashRefreshToken(refreshToken);
            var sessionId = Guid.NewGuid();
            var expiry = DateTime.UtcNow.Add(RefreshLifetime);
            return await transactions.ExecuteAsync<AuthTokenResult?>(async (connection, transaction, token) =>
            {
                var user = await users.GetByEmailAsync(email.Trim(), connection, transaction, token);
                if (user is null || !user.IsActive || user.DeleteDate.HasValue)
                    return null;

                var verification = passwordHasher.VerifyHashedPassword(user, user.PasswordHash, password);
                if (verification == PasswordVerificationResult.Failed) return null;
                if (verification == PasswordVerificationResult.SuccessRehashNeeded)
                    await users.SetPasswordHashAsync(user.Id, passwordHasher.HashPassword(user, password),
                        connection, transaction, token);

                await sessions.CreateAsync(sessionId, user.Id, tokenHash, expiry, connection, transaction, token);
                return IssueTokens(user.Id, refreshToken);
            }, cancellationToken);
        }

        public async Task<AuthTokenResult?> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default)
        {
            if (!IsRefreshTokenFormatValid(refreshToken)) return null;
            var replacement = CreateRefreshToken();
            var newId = Guid.NewGuid();
            var newExpiry = DateTime.UtcNow.Add(RefreshLifetime);
            return await transactions.ExecuteAsync<AuthTokenResult?>(async (connection, transaction, token) =>
            {
                var userId = await sessions.RotateAsync(HashRefreshToken(refreshToken), newId, HashRefreshToken(replacement),
                    newExpiry, connection, transaction, token);
                return userId.HasValue ? IssueTokens(userId.Value, replacement) : null;
            }, cancellationToken);
        }

        public Task LogoutAsync(string refreshToken, CancellationToken cancellationToken = default)
        {
            if (!IsRefreshTokenFormatValid(refreshToken)) return Task.CompletedTask;
            return transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                await sessions.RevokeAsync(HashRefreshToken(refreshToken), connection, transaction, token);
                return true;
            }, cancellationToken);
        }

        private AuthTokenResult IssueTokens(Guid userId, string refreshToken)
        {
            var (accessToken, expiresAtUtc) = accessTokenIssuer.Issue(userId);
            return new AuthTokenResult(accessToken, refreshToken, expiresAtUtc);
        }

        private static string ValidateEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email) || email.Length > 320 ||
                !MailAddress.TryCreate(email.Trim(), out var parsed) || parsed.Address != email.Trim())
                throw new ArgumentException("A valid email address is required.", nameof(email));
            return email.Trim();
        }

        private static void ValidatePassword(string password)
        {
            if (password is null || password.Length < 12 || password.Length > 128)
                throw new ArgumentException("Password must contain 12 to 128 characters.", nameof(password));
        }

        private static string CreateRefreshToken() => Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
        private static bool IsRefreshTokenFormatValid(string? token)
        {
            if (token?.Length != 88) return false;
            try { return Convert.FromBase64String(token).Length == 64; }
            catch (FormatException) { return false; }
        }
        private static byte[] HashRefreshToken(string token) => SHA256.HashData(Convert.FromBase64String(token));
    }
}

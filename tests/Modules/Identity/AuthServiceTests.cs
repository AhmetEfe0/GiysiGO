using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;
using GiysiGo.Modules.Identity.Infrastructure;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;

namespace GiysiGo.Modules.Identity.Tests
{
    [Collection(nameof(IdentityDatabaseCollection))]
    public sealed class AuthServiceTests
    {
        [SqlServerFact]
        public async Task Register_login_rotate_replay_and_logout_follow_one_session_chain()
        {
            using var db = new IdentityDatabase();
            var issuer = new TestAccessTokenIssuer();
            var auth = new AuthService(db.Transactions, db.Get<IUserRepository>(),
                db.Get<IAuthSessionRepository>(), db.Get<IIdentityAccessRepository>(),
                new PasswordHasher<User>(), issuer);
            var email = $"auth-{Guid.NewGuid():N}@example.test";
            var userId = await auth.RegisterAsync(email, "a-long-unique-password");

            var user = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                db.Get<IUserRepository>().GetByEmailAsync(email, connection, transaction, token));
            Assert.NotNull(user);
            Assert.Equal(userId, user.Id);
            Assert.NotEqual("a-long-unique-password", user.PasswordHash);
            var roles = await db.Transactions.ExecuteAsync((connection, transaction, token) =>
                db.Get<IIdentityAccessRepository>().GetUserRoleListAsync(userId, connection, transaction, token));
            Assert.Single(roles);

            Assert.Null(await auth.LoginAsync(email, "wrong-password"));
            var login = await auth.LoginAsync(email.ToUpperInvariant(), "a-long-unique-password");
            Assert.NotNull(login);
            Assert.Equal(userId.ToString(), login.AccessToken);

            issuer.FailIssuance = true;
            await Assert.ThrowsAsync<InvalidOperationException>(() => auth.RefreshAsync(login.RefreshToken));
            issuer.FailIssuance = false;

            var rotations = await Task.WhenAll(auth.RefreshAsync(login.RefreshToken),
                auth.RefreshAsync(login.RefreshToken));
            var rotated = Assert.Single(rotations, result => result is not null);
            Assert.NotNull(rotated);
            Assert.NotEqual(login.RefreshToken, rotated.RefreshToken);
            Assert.Null(await auth.RefreshAsync(login.RefreshToken));

            await auth.LogoutAsync(rotated.RefreshToken);
            Assert.Null(await auth.RefreshAsync(rotated.RefreshToken));
            await auth.LogoutAsync(rotated.RefreshToken);

            await Assert.ThrowsAnyAsync<SqlException>(() =>
                auth.RegisterAsync(email.ToUpperInvariant(), "another-unique-password"));
            await db.Transactions.ExecuteAsync(async (connection, transaction, token) =>
            {
                await db.Get<IUserRepository>().SetActiveAsync(userId, false, connection, transaction, token);
                return true;
            });
            Assert.Null(await auth.LoginAsync(email, "a-long-unique-password"));
        }
    }
}

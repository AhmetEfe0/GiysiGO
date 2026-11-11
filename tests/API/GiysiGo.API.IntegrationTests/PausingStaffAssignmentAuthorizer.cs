using System.Data;
using System.Data.Common;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Authorization;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Infrastructure;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class PausingStaffAssignmentAuthorizer(IIdentityAuthorizationRepository repository, IStoreScopeReader stores,
        TaskCompletionSource<(IsolationLevel Isolation, int Session)> authorized, Task resume) : IStaffAssignmentAuthorizer
    {
        public async Task<bool> CanManageAsync(Guid actorUserId, Guid targetUserId, Guid targetRoleId,
            Guid? corporateId, Guid? storeId, DbConnection connection, DbTransaction transaction,
            CancellationToken cancellationToken = default)
        {
            var allowed = await new StaffAssignmentAuthorizer(repository, stores).CanManageAsync(actorUserId, targetUserId,
                targetRoleId, corporateId, storeId, connection, transaction, cancellationToken);
            if (allowed)
            {
                authorized.TrySetResult((transaction.IsolationLevel, ((SqlConnection)connection).ServerProcessId));
                await resume.WaitAsync(TimeSpan.FromSeconds(20), cancellationToken);
            }
            return allowed;
        }
    }
}

using GiysiGo.BuildingBlocks.Application.Contracts;
using Microsoft.AspNetCore.Authorization;

namespace GiysiGo.API.Authorization
{
    public static class PermissionPolicies
    {
        public static void AddPermissionPolicies(AuthorizationOptions options)
        {
            string[] codes =
            [
                PermissionCodes.StoreView,
                PermissionCodes.StoreStaffManage,
                PermissionCodes.StoreOfferingManage,
                PermissionCodes.OrderView,
                PermissionCodes.OrderInspect,
                PermissionCodes.QuotePrepare,
                PermissionCodes.QuoteApprove,
                PermissionCodes.OrderProcess,
                PermissionCodes.OrderFulfill
            ];

            foreach (var code in codes)
            {
                options.AddPolicy(code, policy => policy.RequireAuthenticatedUser()
                    .AddRequirements(new PermissionRequirement(code)));
            }
        }
    }
}

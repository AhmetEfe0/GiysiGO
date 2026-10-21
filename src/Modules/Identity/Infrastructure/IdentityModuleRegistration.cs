using Microsoft.Extensions.DependencyInjection;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Identity.Application.Interfaces.Authorization;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;
using GiysiGo.Modules.Identity.Infrastructure.Repositories;
using Microsoft.AspNetCore.Identity;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public static class IdentityModuleRegistration
    {
        public static IServiceCollection AddIdentityModule(this IServiceCollection services)
        {
            services.AddHttpContextAccessor();
            services.AddScoped<ICurrentUser, CurrentUser>();
            services.AddScoped<IPermissionChecker, PermissionChecker>();
            services.AddScoped<IStaffAssignmentAuthorizer, StaffAssignmentAuthorizer>();
            services.AddScoped<IIdentityAuthorizationRepository, IdentityAuthorizationRepository>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IAuthSessionRepository, AuthSessionRepository>();
            services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
            services.AddScoped<ICorporateRepository, CorporateRepository>();
            services.AddScoped<IRoleRepository, RoleRepository>();
            services.AddScoped<IPermissionRepository, PermissionRepository>();
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<ICustomerAddressRepository, CustomerAddressRepository>();
            services.AddScoped<IIdentityAccessRepository, IdentityAccessRepository>();
            return services;
        }
    }
}

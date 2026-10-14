using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.Modules.Identity.Infrastructure
{
    public static class IdentityModuleRegistration
    {
        public static IServiceCollection AddIdentityModule(this IServiceCollection services)
        {
            return services;
        }
    }
}

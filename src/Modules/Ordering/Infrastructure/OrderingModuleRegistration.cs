using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.Modules.Ordering.Infrastructure
{
    public static class OrderingModuleRegistration
    {
        public static IServiceCollection AddOrderingModule(this IServiceCollection services)
        {
            return services;
        }
    }
}

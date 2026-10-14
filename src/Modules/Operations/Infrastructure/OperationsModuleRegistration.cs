using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.Modules.Operations.Infrastructure
{
    public static class OperationsModuleRegistration
    {
        public static IServiceCollection AddOperationsModule(this IServiceCollection services)
        {
            return services;
        }
    }
}

using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.Modules.Catalog.Infrastructure
{
    public static class CatalogModuleRegistration
    {
        public static IServiceCollection AddCatalogModule(this IServiceCollection services)
        {
            return services;
        }
    }
}

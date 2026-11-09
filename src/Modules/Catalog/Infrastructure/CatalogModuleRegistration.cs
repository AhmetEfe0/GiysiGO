using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Infrastructure.Repositories;
using Microsoft.Extensions.DependencyInjection;
using GiysiGo.BuildingBlocks.Application.Contracts;

namespace GiysiGo.Modules.Catalog.Infrastructure
{

    public static class CatalogModuleRegistration
    {
        public static IServiceCollection AddCatalogModule(this IServiceCollection services)
        {
            services.AddScoped<ICatalogRepository, CatalogRepository>();
            services.AddScoped<ICatalogManagementRepository, CatalogManagementRepository>();
            services.AddScoped<IStoreScopeReader, StoreScopeReader>();

            return services;
        }
    }
}

using GiysiGo.Modules.Catalog.Application.Repositories;
using GiysiGo.Modules.Catalog.Infrastructure.Repositories;
using Microsoft.Extensions.DependencyInjection;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.Modules.Catalog.Application.Stores;

namespace GiysiGo.Modules.Catalog.Infrastructure
{

    public static class CatalogModuleRegistration
    {
        public static IServiceCollection AddCatalogModule(this IServiceCollection services)
        {
            services.AddScoped<ICatalogRepository, CatalogRepository>();
            services.AddScoped<ICatalogManagementRepository, CatalogManagementRepository>();
            services.AddScoped<IStoreScopeReader, StoreScopeReader>();

            services.AddScoped<IStoreManagementRepository, StoreManagementRepository>();
            services.AddScoped<StoreManagementService>();
            services.AddScoped<IStoreOfferingManagementRepository, StoreOfferingManagementRepository>();
            services.AddScoped<GiysiGo.Modules.Catalog.Application.Offerings.StoreOfferingManagementService>();
            services.AddScoped<StoreCatalogReader>();
            services.AddScoped<IStoreCatalogReader>(provider => provider.GetRequiredService<StoreCatalogReader>());
            services.AddScoped<ITransactionalStoreCatalogReader>(provider => provider.GetRequiredService<StoreCatalogReader>());
            return services;
        }
    }
}

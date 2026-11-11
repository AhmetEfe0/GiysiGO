using Microsoft.Extensions.DependencyInjection;
using GiysiGo.Modules.Ordering.Application.Contracts;
using GiysiGo.Modules.Ordering.Infrastructure.Repositories;
using GiysiGo.Modules.Ordering.Infrastructure.Storage;
using GiysiGo.Modules.Ordering.Application;

namespace GiysiGo.Modules.Ordering.Infrastructure
{
    public static class OrderingModuleRegistration
    {
        public static IServiceCollection AddOrderingModule(this IServiceCollection services)
        {
            services.AddScoped<ICartCommandRepository, SqlCartCommandRepository>();
            services.AddScoped<ICartQueryRepository, SqlCartQueryRepository>();
            services.AddScoped<ICartPhotoStorage, LocalCartPhotoStorage>();
            services.AddScoped<IOrderWorkflowRepository, SqlOrderWorkflowRepository>();
            services.AddScoped<IOrderingWorkflowService>(serviceProvider =>
                ActivatorUtilities.CreateInstance<OrderingWorkflowService>(serviceProvider));
            services.AddScoped<ICartCommandService>(serviceProvider =>
                ActivatorUtilities.CreateInstance<CartCommandService>(serviceProvider));
            services.AddScoped<ICartQueryService>(serviceProvider =>
                ActivatorUtilities.CreateInstance<CartQueryService>(serviceProvider));
            return services;
        }
    }
}

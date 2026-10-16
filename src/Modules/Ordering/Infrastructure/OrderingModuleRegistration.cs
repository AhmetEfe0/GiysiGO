using Microsoft.Extensions.DependencyInjection;
using GiysiGo.Modules.Ordering.Application.Contracts;
using GiysiGo.Modules.Ordering.Infrastructure.Repositories;
using GiysiGo.Modules.Ordering.Application;

namespace GiysiGo.Modules.Ordering.Infrastructure
{
    public static class OrderingModuleRegistration
    {
        public static IServiceCollection AddOrderingModule(this IServiceCollection services)
        {
            services.AddScoped<ICartCommandRepository, SqlCartCommandRepository>();
            services.AddScoped<IOrderWorkflowRepository, SqlOrderWorkflowRepository>();
            services.AddScoped<IOrderingWorkflowService, OrderingWorkflowService>();
            services.AddScoped<ICartCommandService, CartCommandService>();
            return services;
        }
    }
}

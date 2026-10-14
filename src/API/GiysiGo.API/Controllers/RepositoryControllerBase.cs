using GiysiGo.BuildingBlocks.Application;
using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.API.Controllers
{
    public abstract class RepositoryControllerBase<TEntity>(IRepository<TEntity> repository) : AuthenticatedApiControllerBase where TEntity : IEntityBase<Guid>
    {
        protected IRepository<TEntity> Repository { get; } = repository;
    }
}

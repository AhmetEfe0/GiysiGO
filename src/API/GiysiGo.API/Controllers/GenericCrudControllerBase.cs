using GiysiGo.BuildingBlocks.Application;
using GiysiGo.BuildingBlocks.Domain;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers
{
    public abstract class GenericCrudControllerBase<TEntity>(
        IRepository<TEntity> repository) : RepositoryControllerBase<TEntity>(repository)
        where TEntity : class, IEntityBase<Guid>
    {
        protected virtual ValueTask<bool> CanListAsync(Guid userId, CancellationToken cancellationToken)
            => ValueTask.FromResult(false);

        protected virtual ValueTask<bool> CanReadAsync(Guid userId, TEntity entity, CancellationToken cancellationToken)
            => ValueTask.FromResult(false);

        protected virtual ValueTask<bool> CanCreateAsync(Guid userId, TEntity entity, CancellationToken cancellationToken)
            => ValueTask.FromResult(false);

        protected virtual ValueTask<bool> CanUpdateAsync(
            Guid userId, TEntity existing, TEntity requested, CancellationToken cancellationToken)
            => ValueTask.FromResult(false);

        protected virtual ValueTask<bool> CanDeleteAsync(Guid userId, TEntity entity, CancellationToken cancellationToken)
            => ValueTask.FromResult(false);

        [HttpGet]
        public virtual async Task<IActionResult> GetAll(CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            if (!await CanListAsync(userId, cancellationToken)) return Forbid();
            return Ok(await Repository.GetAllAsync(cancellationToken));
        }

        [HttpGet("{id:guid}")]
        public virtual async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var entity = await Repository.GetByIdAsync(id, cancellationToken);
            if (entity is null) return NotFound();
            if (!await CanReadAsync(userId, entity, cancellationToken)) return Forbid();
            return Ok(entity);
        }

        [HttpPost]
        public virtual async Task<IActionResult> Insert([FromBody] TEntity entity, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            entity.Id = Guid.NewGuid();
            entity.CreateDate = DateTime.UtcNow;
            entity.UpdateDate = null;
            entity.DeleteDate = null;
            if (!await CanCreateAsync(userId, entity, cancellationToken)) return Forbid();
            var id = await Repository.InsertAsync(entity, cancellationToken);
            return StatusCode(StatusCodes.Status201Created, new { id });
        }

        [HttpPut("{id:guid}")]
        public virtual async Task<IActionResult> Update(
            Guid id, [FromBody] TEntity entity, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var existing = await Repository.GetByIdAsync(id, cancellationToken);
            if (existing is null) return NotFound();
            entity.Id = id;
            entity.CreateDate = existing.CreateDate;
            entity.UpdateDate = DateTime.UtcNow;
            entity.DeleteDate = existing.DeleteDate;
            if (!await CanUpdateAsync(userId, existing, entity, cancellationToken)) return Forbid();
            await Repository.UpdateAsync(entity, cancellationToken);
            return NoContent();
        }

        [HttpDelete("{id:guid}")]
        public virtual async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Unauthorized();
            var entity = await Repository.GetByIdAsync(id, cancellationToken);
            if (entity is null) return NotFound();
            if (!await CanDeleteAsync(userId, entity, cancellationToken)) return Forbid();

            await Repository.DeleteAsync(id, cancellationToken);
            return NoContent();
        }
    }
}

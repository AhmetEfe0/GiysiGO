namespace GiysiGo.BuildingBlocks.Domain
{
    public abstract class EntityBase<TId> : IEntityBase<TId>
    {
        public TId Id { get; set; } = default!;
        public DateTime CreateDate { get; set; }
        public DateTime? UpdateDate { get; set; }
        public DateTime? DeleteDate { get; set; }
    }
}

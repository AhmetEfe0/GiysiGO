namespace GiysiGo.BuildingBlocks.Domain
{
    public interface IEntityBase<TId>
    {
        TId Id { get; set; }
        DateTime CreateDate { get; set; }
        DateTime? UpdateDate { get; set; }
        DateTime? DeleteDate { get; set; }
    }
}

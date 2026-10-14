namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface ICurrentUser
    {
        Guid? UserId { get; }
        bool IsAuthenticated { get; }
    }
}

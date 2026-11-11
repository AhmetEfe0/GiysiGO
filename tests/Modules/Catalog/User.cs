using GiysiGo.BuildingBlocks.Application.Contracts;
namespace GiysiGo.Modules.Catalog.Tests
{
    internal sealed class User(bool authenticated = true) : ICurrentUser
    {
        public Guid? UserId { get; } = Guid.NewGuid();
        public bool IsAuthenticated => authenticated;
    }
}

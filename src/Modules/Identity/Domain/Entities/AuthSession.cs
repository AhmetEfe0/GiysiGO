using GiysiGo.BuildingBlocks.Domain;

namespace GiysiGo.Modules.Identity.Domain.Entities
{
    public sealed class AuthSession : EntityBase<Guid>
    {
        public Guid UserId { get; set; }
        public byte[] TokenHash { get; set; } = [];
        public DateTime ExpiresAtUtc { get; set; }
        public DateTime? RevokedAtUtc { get; set; }
        public Guid? ReplacedById { get; set; }
    }
}

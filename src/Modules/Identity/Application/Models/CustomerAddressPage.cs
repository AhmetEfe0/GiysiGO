using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Application.Models
{
    public sealed record CustomerAddressPage(IReadOnlyList<CustomerAddress> Items, int TotalCount);
}

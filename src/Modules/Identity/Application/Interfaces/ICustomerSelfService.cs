using GiysiGo.Modules.Identity.Application.Models;
using GiysiGo.Modules.Identity.Domain.Entities;

namespace GiysiGo.Modules.Identity.Application.Interfaces
{
    public interface ICustomerSelfService
    {
        Task<CustomerProfile?> GetProfileAsync(Guid userId, CancellationToken cancellationToken = default);
        Task<CustomerProfile?> UpdateProfileAsync(Guid userId, string email, CancellationToken cancellationToken = default);
        Task<IReadOnlyList<CustomerAddress>> GetAddressesAsync(Guid userId, CancellationToken cancellationToken = default);
        Task<CustomerAddressPage> GetAddressPageAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken = default);
        Task<CustomerAddress?> GetAddressAsync(Guid userId, Guid addressId, CancellationToken cancellationToken = default);
        Task<Guid> CreateAddressAsync(Guid userId, CustomerAddressInput input, CancellationToken cancellationToken = default);
        Task<bool> UpdateAddressAsync(Guid userId, Guid addressId, CustomerAddressInput input, CancellationToken cancellationToken = default);
        Task<bool> DeleteAddressAsync(Guid userId, Guid addressId, CancellationToken cancellationToken = default);
    }
}

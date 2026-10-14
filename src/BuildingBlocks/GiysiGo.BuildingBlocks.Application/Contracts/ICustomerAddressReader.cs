namespace GiysiGo.BuildingBlocks.Application.Contracts
{
    public interface ICustomerAddressReader
    {
        Task<CustomerAddressSnapshot?> GetOwnedAddressAsync(Guid customerId, Guid addressId, CancellationToken cancellationToken = default);
    }
}

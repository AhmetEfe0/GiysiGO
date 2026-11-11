namespace GiysiGo.Modules.Ordering.Application.Contracts
{
    public interface ICartPhotoStorage
    {
        Task<string> StoreAsync(Stream content, CancellationToken cancellationToken = default);
        Task<StoredCartPhoto?> OpenReadAsync(string storageKey, CancellationToken cancellationToken = default);
        Task DeleteAsync(string storageKey, CancellationToken cancellationToken = default);
    }
}

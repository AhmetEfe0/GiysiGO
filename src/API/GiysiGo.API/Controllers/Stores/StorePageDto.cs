namespace GiysiGo.API.Controllers.Stores
{
    public sealed record StorePageDto(IReadOnlyList<StoreDto> Items, int Page, int PageSize, long TotalCount);
}

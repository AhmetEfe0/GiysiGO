namespace GiysiGo.API.Controllers.Identity
{
    public sealed record AddressPage(IReadOnlyList<AddressResponse> Items, int Page, int PageSize, int TotalCount);
}

using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Catalog
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record CatalogCategoryWriteRequest(
        [Required(ErrorMessage = "Kod gerekli."), StringLength(100, ErrorMessage = "Kod en çok 100 karakter olabilir.")] string Code,
        [Required(ErrorMessage = "Ad gerekli."), StringLength(200, ErrorMessage = "Ad en çok 200 karakter olabilir.")] string Name,
        [Range(0, int.MaxValue, ErrorMessage = "Sıralama negatif olamaz.")] int SortOrder = 0,
        bool IsActive = true);
}

using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using GiysiGo.API.Validation;

namespace GiysiGo.API.Controllers.Catalog
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record CatalogProductTypeWriteRequest(
        [NotEmptyGuid] Guid CategoryId,
        [Required(ErrorMessage = "Kod gerekli."), StringLength(100, ErrorMessage = "Kod en çok 100 karakter olabilir.")] string Code,
        [Required(ErrorMessage = "Ad gerekli."), StringLength(200, ErrorMessage = "Ad en çok 200 karakter olabilir.")] string Name,
        [Required(ErrorMessage = "Birim gerekli."), RegularExpression("^(PIECE|M2)$", ErrorMessage = "Birim PIECE veya M2 olmalıdır.")] string BaseUnit = "PIECE",
        bool IsActive = true);
}

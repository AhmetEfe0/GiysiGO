using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using GiysiGo.API.Validation;

namespace GiysiGo.API.Controllers.Catalog
{
    [JsonUnmappedMemberHandling(JsonUnmappedMemberHandling.Disallow)]
    public sealed record CatalogProductTypeServiceWriteRequest(
        [NotEmptyGuid] Guid ProductTypeId,
        [NotEmptyGuid] Guid ServiceId,
        [property: JsonRequired] [CatalogPrice] decimal DefaultPrice,
        [Required(ErrorMessage = "Birim gerekli."), RegularExpression("^(PIECE|M2)$", ErrorMessage = "Birim PIECE veya M2 olmalıdır.")] string PriceUnit,
        [Required(ErrorMessage = "Seçim türü gerekli."), RegularExpression("^(BASE|ALTERNATIVE|ADD_ON)$", ErrorMessage = "Geçersiz seçim türü.")] string SelectionKind,
        bool IsActive = true);
}

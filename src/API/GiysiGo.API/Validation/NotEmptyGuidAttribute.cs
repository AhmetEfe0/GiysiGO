using System.ComponentModel.DataAnnotations;

namespace GiysiGo.API.Validation
{
    public sealed class NotEmptyGuidAttribute : ValidationAttribute
    {
        public NotEmptyGuidAttribute() : base("Kimlik boş olamaz.") { }
        public override bool IsValid(object? value) => value is Guid id && id != Guid.Empty;
    }
}

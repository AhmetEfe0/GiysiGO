using System.ComponentModel.DataAnnotations;

namespace GiysiGo.API.Controllers.Ordering
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Parameter)]
    public sealed class NotEmptyGuidAttribute : ValidationAttribute
    {
        public override bool IsValid(object? value) => value is Guid id && id != Guid.Empty;
    }
}

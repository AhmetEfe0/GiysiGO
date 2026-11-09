using System.ComponentModel.DataAnnotations;

namespace GiysiGo.API.Validation
{
    public sealed class CatalogPriceAttribute : ValidationAttribute
    {
        public CatalogPriceAttribute() : base("Fiyat 0 ile 9999999999,99 arasında ve en çok iki ondalık basamaklı olmalıdır.") { }
        public override bool IsValid(object? value) => value is decimal amount && amount >= 0
            && amount <= 9999999999.99m && decimal.Round(amount, 2) == amount;
    }
}

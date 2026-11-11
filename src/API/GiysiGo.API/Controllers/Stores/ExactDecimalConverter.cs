using System.Buffers;
using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace GiysiGo.API.Controllers.Stores
{
    // Ölçüleri doğrulamadan önce JSON okuyucusunun sessizce yuvarlamasını engeller.
    public sealed class ExactDecimalConverter : JsonConverter<decimal>
    {
        public override decimal Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType != JsonTokenType.Number || !reader.TryGetDecimal(out var value))
                throw new JsonException("Ölçü geçerli bir ondalık sayı olmalıdır.");

            var raw = reader.HasValueSequence
                ? Encoding.UTF8.GetString(reader.ValueSequence.ToArray())
                : Encoding.UTF8.GetString(reader.ValueSpan);
            try
            {
                if (Normalize(raw) != Normalize(value.ToString(CultureInfo.InvariantCulture)))
                    throw new JsonException("Ölçü hassasiyet kaybı olmadan okunabilmelidir.");
            }
            catch (Exception exception) when (exception is FormatException or OverflowException)
            {
                throw new JsonException("Ölçünün sayı gösterimi desteklenmiyor.", exception);
            }
            return value;
        }

        public override void Write(Utf8JsonWriter writer, decimal value, JsonSerializerOptions options) => writer.WriteNumberValue(value);

        private static (bool Negative, string Digits, long Exponent) Normalize(string text)
        {
            var negative = text.StartsWith('-');
            if (negative) text = text[1..];
            var exponentIndex = text.IndexOfAny(['e', 'E']);
            var exponent = exponentIndex < 0 ? 0L : long.Parse(text[(exponentIndex + 1)..], NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture);
            var mantissa = exponentIndex < 0 ? text : text[..exponentIndex];
            var point = mantissa.IndexOf('.');
            var fractionalDigits = point < 0 ? 0 : mantissa.Length - point - 1;
            var digits = mantissa.Replace(".", "").TrimStart('0');
            if (digits.Length == 0) return (false, "0", 0);
            var significant = digits.TrimEnd('0');
            return (negative, significant, checked(exponent - fractionalDigits + digits.Length - significant.Length));
        }
    }
}

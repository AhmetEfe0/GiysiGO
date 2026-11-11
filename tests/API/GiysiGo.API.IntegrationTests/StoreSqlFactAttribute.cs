namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreSqlFactAttribute : FactAttribute
    {
        public StoreSqlFactAttribute()
        {
            if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("GIYSIGO_STORE_TEST_CONNECTION")))
                Skip = "Ayrılmış SQL doğrulaması için GIYSIGO_STORE_TEST_CONNECTION gereklidir.";
        }
    }
}

namespace GiysiGo.API.IntegrationTests
{
    public sealed class CatalogDatabaseFactAttribute : FactAttribute
    {
        public CatalogDatabaseFactAttribute()
        {
            if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")))
                Skip = "GIYSIGO_CATALOG_TEST_CONNECTION ayrılmış katalog test veritabanını göstermelidir.";
        }
    }
}

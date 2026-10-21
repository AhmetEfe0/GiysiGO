namespace GiysiGo.Modules.Catalog.Tests.IntegrationTests;

public sealed class CatalogSqlServerFactAttribute : FactAttribute
{
    public CatalogSqlServerFactAttribute()
    {
        if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")))
            Skip = "Set GIYSIGO_CATALOG_TEST_CONNECTION to a dedicated Catalog test database.";
    }
}

namespace GiysiGo.Modules.Ordering.Tests
{
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class SqlServerFactAttribute : FactAttribute
    {
        public SqlServerFactAttribute()
        {
            if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("GIYSIGO_ORDERING_TEST_CONNECTION_STRING")))
                Skip = "Set GIYSIGO_ORDERING_TEST_CONNECTION_STRING to a dedicated SQL Server test database with the GiysiGo DACPAC deployed.";
        }
    }
}

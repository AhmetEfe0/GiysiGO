using System.Reflection;

namespace GiysiGo.Modules.Catalog.Tests
{
    public sealed class ModuleBoundaryTests
    {
        [Fact]
        public void Domain_does_not_reference_another_module()
        {
            var domain = Assembly.Load("GiysiGo.Modules.Catalog.Domain");
            var externalModules = domain.GetReferencedAssemblies()
                .Where(reference => reference.Name?.StartsWith("GiysiGo.Modules.", StringComparison.Ordinal) == true
                    && !reference.Name.StartsWith("GiysiGo.Modules.Catalog.", StringComparison.Ordinal))
                .Select(reference => reference.Name);

            Assert.Empty(externalModules);
        }
    }
}

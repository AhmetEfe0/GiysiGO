using System.Reflection;

namespace GiysiGo.Modules.Operations.Tests
{
    public sealed class ModuleBoundaryTests
    {
        [Fact]
        public void Domain_does_not_reference_another_module()
        {
            var domain = Assembly.Load("GiysiGo.Modules.Operations.Domain");
            var externalModules = domain.GetReferencedAssemblies()
                .Where(reference => reference.Name?.StartsWith("GiysiGo.Modules.", StringComparison.Ordinal) == true
                    && !reference.Name.StartsWith("GiysiGo.Modules.Operations.", StringComparison.Ordinal))
                .Select(reference => reference.Name);

            Assert.Empty(externalModules);
        }
    }
}

using System.Text.Json;

namespace GiysiGo.Modules.Catalog.Tests
{

    public sealed class CatalogDraftTests
    {
        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };

        [Fact]
        public async Task Draft_uses_unique_stable_codes_and_valid_product_service_references()
        {
            var draft = await LoadDraftAsync();
            var categoryCodes = draft.Categories.Select(category => category.Code).ToHashSet(StringComparer.Ordinal);
            var productIds = draft.Products.Select(product => product.Id).ToHashSet(StringComparer.Ordinal);
            var serviceIds = draft.Services.Select(service => service.Id).ToHashSet(StringComparer.Ordinal);

            Assert.Equal(draft.Categories.Count, categoryCodes.Count);
            Assert.Equal(draft.Products.Count, productIds.Count);
            Assert.Equal(draft.Services.Count, serviceIds.Count);
            Assert.All(draft.Products, product => Assert.Contains(product.CategoryCode, categoryCodes));
            Assert.All(draft.ProductServices, combination =>
            {
                Assert.Contains(combination.ProductId, productIds);
                Assert.Contains(combination.ServiceId, serviceIds);
                Assert.True(combination.DefaultPriceTry >= 0);
                Assert.Contains(combination.Kind, new[] { "BASE", "ALTERNATIVE", "ADD_ON" });
                Assert.True(combination.PriceUnit is null or "PIECE" or "M2");
            });

            Assert.Equal(draft.ProductServices.Count,
                draft.ProductServices.Select(combination => (combination.ProductId, combination.ServiceId)).Distinct().Count());
        }

        [Fact]
        public async Task Every_product_has_one_marked_base_and_user_decisions_override_source_defaults()
        {
            var draft = await LoadDraftAsync();
            var decisions = await LoadDecisionsAsync();

            foreach (var product in draft.Products)
            {
                var baseServices = draft.ProductServices
                    .Where(combination => combination.ProductId == product.Id && combination.Kind == "BASE")
                    .ToArray();

                Assert.Single(baseServices);
            }

            var sourceRowsMissingUnits = draft.ProductServices
                .Where(combination => combination.PriceUnit is null)
                .Select(combination => (combination.ProductId, combination.ServiceId))
                .ToHashSet();

            var unitOverrides = decisions.ProductServiceUnitOverrides
                .Select(overrideRow => (overrideRow.ProductId, overrideRow.ServiceId, overrideRow.PriceUnit))
                .ToHashSet();
            Assert.Equal(3, sourceRowsMissingUnits.Count);
            Assert.Contains(("P040", "S028", "M2"), unitOverrides);
            Assert.Contains(("P040", "S105", "M2"), unitOverrides);
            Assert.Contains(("P041", "S013", "M2"), unitOverrides);
            Assert.Equal(16, draft.TailoringEntry.Count);
            Assert.Equal(24, decisions.TailoringEntryMappings.Count);
            var decidedIndexes = decisions.TailoringEntryMappings.Select(row => row.TailoringEntryIndex)
                .Concat(decisions.ExcludedTailoringEntries.Select(row => row.TailoringEntryIndex))
                .Distinct().Order().ToArray();
            Assert.Equal(Enumerable.Range(0, draft.TailoringEntry.Count), decidedIndexes);
            Assert.All(decisions.TailoringEntryMappings, mapping =>
            {
                Assert.DoesNotContain(decisions.ExcludedTailoringEntries, exclusion => exclusion.TailoringEntryIndex == mapping.TailoringEntryIndex);
                Assert.Contains(draft.ProductServices, pair => pair.ProductId == mapping.ProductId && pair.ServiceId == mapping.ServiceId);
            });
            Assert.Equal(0, decisions.TailoringEntryMappings[0].TailoringEntryIndex);
            Assert.Equal("P006", decisions.TailoringEntryMappings[0].ProductId);
            Assert.Equal("S023", decisions.TailoringEntryMappings[0].ServiceId);
            Assert.Equal(2, decisions.TailoringEntryMappings[1].TailoringEntryIndex);
            Assert.Equal("P006", decisions.TailoringEntryMappings[1].ProductId);
            Assert.Equal("S024", decisions.TailoringEntryMappings[1].ServiceId);
            Assert.Equal(3, decisions.TailoringEntryMappings[2].TailoringEntryIndex);
            Assert.Equal("P006", decisions.TailoringEntryMappings[2].ProductId);
            Assert.Equal("S025", decisions.TailoringEntryMappings[2].ServiceId);
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 4 && row.ProductId == "P006" && row.ServiceId == "S019");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 4 && row.ProductId == "P007" && row.ServiceId == "S030");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 5 && row.ProductId == "P014" && row.ServiceId == "S046");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 6 && row.ProductId == "P009" && row.ServiceId == "S030");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 6 && row.ProductId == "P028" && row.ServiceId == "S030");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 7 && row.ProductId == "P012" && row.ServiceId == "S038");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 8 && row.ProductId == "P012" && row.ServiceId == "S039");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 9 && row.ProductId == "P001" && row.ServiceId == "S003");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 10 && row.ProductId == "P007" && row.ServiceId == "S028");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 10 && row.ProductId == "P009" && row.ServiceId == "S028");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 10 && row.ProductId == "P027" && row.ServiceId == "S028");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 11 && row.ProductId == "P001" && row.ServiceId == "S004");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 11 && row.ProductId == "P002" && row.ServiceId == "S009");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 12 && row.ProductId == "P012" && row.ServiceId == "S009");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 14 && row.ProductId == "P002" && row.ServiceId == "S010");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 14 && row.ProductId == "P003" && row.ServiceId == "S014");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 14 && row.ProductId == "P012" && row.ServiceId == "S040");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 14 && row.ProductId == "P014" && row.ServiceId == "S047");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 14 && row.ProductId == "P015" && row.ServiceId == "S049");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 15 && row.ProductId == "P001" && row.ServiceId == "S005");
            Assert.Contains(decisions.TailoringEntryMappings, row => row.TailoringEntryIndex == 15 && row.ProductId == "P013" && row.ServiceId == "S045");
            Assert.Contains(decisions.ExcludedTailoringEntries, row => row.TailoringEntryIndex == 1);
            Assert.Contains(decisions.ExcludedTailoringEntries, row => row.TailoringEntryIndex == 13);
            Assert.Equal("none", decisions.InitialServiceSelection);
            Assert.True(decisions.ServiceSelectionRequired);
            Assert.True(decisions.MinimumPrimarySelection);
            Assert.Equal("map-to-existing-product-service", decisions.TailoringEntryPolicy);
        }

        [Fact]
        public async Task Generated_seed_contains_only_decided_product_service_pairs()
        {
            var draft = await LoadDraftAsync();
            var decisions = await LoadDecisionsAsync();
            var path = Path.Combine(AppContext.BaseDirectory, "Catalog", "CatalogSeed.sql");
            var seed = await File.ReadAllTextAsync(path);
            var seededPairs = System.Text.RegularExpressions.Regex.Matches(seed, "-- Seed çifti [A-Z0-9]+/[A-Z0-9]+ ")
                .Count;

            Assert.Equal(draft.ProductServices.Count - decisions.PendingProductServices.Count - decisions.ExcludedProductServices.Count, seededPairs);
            Assert.Contains("-- Seed çifti P006/S023 (PIECE, ADD_ON; terzi kalemi 1)", seed);
            Assert.Contains("-- Kapsam dışı terzi kalemi 2:", seed);
            Assert.Contains("-- Kapsam dışı terzi kalemi 14:", seed);
            Assert.Contains("-- Seed çifti P040/S028 (M2, ADD_ON)", seed);
            Assert.Contains("-- Seed çifti P040/S105 (M2, ADD_ON)", seed);
            Assert.Contains("-- Seed çifti P041/S013 (M2, ADD_ON)", seed);
            Assert.Contains("-- Seed çifti P037/S099 (PIECE, ADD_ON)", seed);
            Assert.Contains("-- Seed çifti P044/S112 (PIECE, ALTERNATIVE)", seed);
            Assert.Contains("-- Kapsam dışında P039/S102:", seed);
            Assert.DoesNotContain("-- Seed çifti P039/S102", seed);
        }

        private static async Task<CatalogDraft> LoadDraftAsync()
        {
            var path = Path.Combine(AppContext.BaseDirectory, "Catalog", "catalog-draft.json");
            var json = await File.ReadAllTextAsync(path);
            return JsonSerializer.Deserialize<CatalogDraft>(json, JsonOptions)
                ?? throw new InvalidDataException("Katalog taslağı JSON verisinden okunamadı.");
        }

        private static async Task<CatalogDecisions> LoadDecisionsAsync()
        {
            var path = Path.Combine(AppContext.BaseDirectory, "Catalog", "catalog-decisions.json");
            var json = await File.ReadAllTextAsync(path);
            return JsonSerializer.Deserialize<CatalogDecisions>(json, JsonOptions)
                ?? throw new InvalidDataException("Katalog kararları JSON verisinden okunamadı.");
        }

        private sealed record CatalogDraft(
            List<Category> Categories,
            List<Product> Products,
            List<Service> Services,
            List<ProductService> ProductServices,
            List<TailoringEntry> TailoringEntry);

        private sealed record Category(string Code, string Name);
        private sealed record Product(string Id, string CategoryCode, string Name, string BaseUnit);
        private sealed record Service(string Id, string Name);
        private sealed record ProductService(
            string ProductId,
            string ServiceId,
            decimal DefaultPriceTry,
            string? PriceUnit,
            bool DefaultSelected,
            string Kind);
        private sealed record TailoringEntry(string Name, bool DefaultSelected, bool IsAddOn, decimal Price);
        private sealed record CatalogDecisions(
            string InitialServiceSelection,
            bool ServiceSelectionRequired,
            bool? MinimumPrimarySelection,
            List<ProductServiceUnitOverride> ProductServiceUnitOverrides,
            string TailoringEntryPolicy,
            List<TailoringEntryMapping> TailoringEntryMappings,
            List<ExcludedTailoringEntry> ExcludedTailoringEntries,
            List<ProductServiceKindOverride> ProductServiceKindOverrides,
            List<ProductServiceDecision> ExcludedProductServices,
            List<ProductServiceDecision> PendingProductServices);
        private sealed record ProductServiceUnitOverride(string ProductId, string ServiceId, string PriceUnit);
        private sealed record TailoringEntryMapping(int TailoringEntryIndex, string ProductId, string ServiceId);
        private sealed record ExcludedTailoringEntry(int TailoringEntryIndex, string Reason);
        private sealed record ProductServiceKindOverride(string ProductId, string ServiceId, string SelectionKind);
        private sealed record ProductServiceDecision(string ProductId, string ServiceId, string Reason);
    }
}

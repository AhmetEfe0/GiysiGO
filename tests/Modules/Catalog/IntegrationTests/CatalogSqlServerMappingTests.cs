using System.Data;
using Dapper;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Catalog.Domain;
using GiysiGo.Modules.Catalog.Infrastructure.Repositories;

namespace GiysiGo.Modules.Catalog.Tests.IntegrationTests;

public sealed class CatalogSqlServerMappingTests
{
    [CatalogSqlServerFact]
    public async Task Catalog_repository_maps_entities_and_filters_store_offerings_by_product_type_service()
    {
        var connectionString = Environment.GetEnvironmentVariable("GIYSIGO_CATALOG_TEST_CONNECTION")!;
        var connectionFactory = new SqlConnectionFactory(connectionString);
        var repository = new CatalogRepository(connectionFactory);

        var fixture = new
        {
            CategoryId = Guid.NewGuid(),
            CategoryCode = $"catalog-filter-{Guid.NewGuid():N}",
            ProductTypeId = Guid.NewGuid(),
            ProductTypeCode = $"catalog-filter-{Guid.NewGuid():N}",
            ServiceId = Guid.NewGuid(),
            ServiceCode = $"catalog-filter-{Guid.NewGuid():N}",
            OtherServiceId = Guid.NewGuid(),
            OtherServiceCode = $"catalog-filter-{Guid.NewGuid():N}",
            CorporateId = Guid.NewGuid(),
            StoreId = Guid.NewGuid(),
            OtherStoreId = Guid.NewGuid(),
            OfferingId = Guid.NewGuid(),
            OtherStoreOfferingId = Guid.NewGuid(),
            UnmatchedOfferingId = Guid.NewGuid()
        };

        var fixtureCreated = false;
        Guid productTypeServiceId = Guid.Empty;
        Guid otherProductTypeServiceId = Guid.Empty;

        try
        {
            await ExecuteFixtureScriptAsync(connectionFactory, "CreateStoreOfferingFilterFixture.sql", fixture);
            fixtureCreated = true;

            var relation = new ProductTypeService
            {
                ProductTypeId = fixture.ProductTypeId,
                ServiceId = fixture.ServiceId,
                DefaultPrice = 123.45m,
                Currency = "TRY",
                PriceUnit = "PIECE",
                SelectionKind = "ADD_ON",
                IsDefaultSelected = false,
                IsActive = true
            };
            productTypeServiceId = await repository.AddProductTypeServiceAsync(relation);

            var otherRelation = new ProductTypeService
            {
                ProductTypeId = fixture.ProductTypeId,
                ServiceId = fixture.OtherServiceId,
                DefaultPrice = 200.00m,
                Currency = "TRY",
                PriceUnit = "M2",
                SelectionKind = "ALTERNATIVE",
                IsDefaultSelected = false,
                IsActive = true
            };
            otherProductTypeServiceId = await repository.AddProductTypeServiceAsync(otherRelation);

            await ExecuteFixtureScriptAsync(connectionFactory, "CreateStoreOfferings.sql", new
            {
                fixture.OfferingId,
                fixture.StoreId,
                ProductTypeServiceId = productTypeServiceId,
                fixture.OtherStoreOfferingId,
                fixture.OtherStoreId,
                fixture.UnmatchedOfferingId,
                OtherProductTypeServiceId = otherProductTypeServiceId
            });

            var categories = await repository.GetCategoriesAsync();
            Assert.Contains(categories, item => item.Id == fixture.CategoryId);
            Assert.NotNull(await repository.GetCategoryByIdAsync(fixture.CategoryId));

            var productTypes = await repository.GetProductTypesAsync(fixture.CategoryId);
            Assert.Contains(productTypes, item => item.Id == fixture.ProductTypeId);
            Assert.Contains(await repository.GetProductTypesPagedAsync(fixture.CategoryId, 1, 10), item => item.Id == fixture.ProductTypeId);
            Assert.NotNull(await repository.GetProductTypeByIdAsync(fixture.ProductTypeId));

            Assert.Contains(await repository.GetServicesAsync(), item => item.Id == fixture.ServiceId);
            Assert.NotNull(await repository.GetServiceByIdAsync(fixture.ServiceId));
            Assert.Contains(await repository.GetStoresAsync(), item => item.Id == fixture.StoreId);
            Assert.NotNull(await repository.GetStoreByIdAsync(fixture.StoreId));

            var relationById = await repository.GetProductTypeServiceByIdAsync(productTypeServiceId);
            Assert.NotNull(relationById);
            Assert.Equal(123.45m, relationById.DefaultPrice);
            Assert.Equal("PIECE", relationById.PriceUnit);
            Assert.Equal("ADD_ON", relationById.SelectionKind);
            Assert.Contains(await repository.GetProductTypeServicesAsync(fixture.ProductTypeId, fixture.ServiceId), item => item.Id == productTypeServiceId);

            var storeOfferings = await repository.GetStoreOfferingsAsync(storeId: fixture.StoreId);
            Assert.Equal(2, storeOfferings.Count);
            Assert.Contains(storeOfferings, item => item.Id == fixture.OfferingId && item.ProductTypeServiceId == productTypeServiceId);
            Assert.Contains(storeOfferings, item => item.Id == fixture.UnmatchedOfferingId && item.ProductTypeServiceId == otherProductTypeServiceId);

            var filteredOfferings = await repository.GetStoreOfferingsAsync(
                storeId: fixture.StoreId,
                productTypeServiceId: productTypeServiceId);
            var matchingOffering = Assert.Single(filteredOfferings);
            Assert.Equal(fixture.OfferingId, matchingOffering.Id);
            Assert.Equal(productTypeServiceId, matchingOffering.ProductTypeServiceId);

            var allMatchingOfferings = await repository.GetStoreOfferingsAsync(productTypeServiceId: productTypeServiceId);
            Assert.Equal(2, allMatchingOfferings.Count);
            Assert.All(allMatchingOfferings, item => Assert.Equal(productTypeServiceId, item.ProductTypeServiceId));
            Assert.NotNull(await repository.GetStoreOfferingByIdAsync(fixture.OfferingId));

            relation.Id = productTypeServiceId;
            relation.DefaultPrice = 124.56m;
            await repository.UpdateProductTypeServiceAsync(relation);
            Assert.Equal(124.56m, (await repository.GetProductTypeServiceByIdAsync(productTypeServiceId))?.DefaultPrice);

            await Assert.ThrowsAsync<Microsoft.Data.SqlClient.SqlException>(
                () => repository.AddProductTypeServiceAsync(relation));

            await repository.DeleteProductTypeServiceAsync(productTypeServiceId);
            var reactivatedId = await repository.AddProductTypeServiceAsync(relation);
            Assert.Equal(productTypeServiceId, reactivatedId);
        }
        finally
        {
            try
            {
                if (fixtureCreated)
                    await ExecuteFixtureScriptAsync(connectionFactory, "DeleteStoreOfferingFilterFixture.sql", fixture);
            }
            finally
            {
                if (productTypeServiceId != Guid.Empty)
                    await repository.DeleteProductTypeServiceAsync(productTypeServiceId);
                if (otherProductTypeServiceId != Guid.Empty)
                    await repository.DeleteProductTypeServiceAsync(otherProductTypeServiceId);
            }
        }
    }

    private static async Task ExecuteFixtureScriptAsync(
        SqlConnectionFactory connectionFactory,
        string fileName,
        object parameters)
    {
        var scriptPath = Path.Combine(AppContext.BaseDirectory, "IntegrationTests", fileName);
        var script = await File.ReadAllTextAsync(scriptPath);
        await using var connection = await connectionFactory.OpenAsync();
        var command = new CommandDefinition(script, parameters, commandType: CommandType.Text);
        await connection.ExecuteAsync(command);
    }
}

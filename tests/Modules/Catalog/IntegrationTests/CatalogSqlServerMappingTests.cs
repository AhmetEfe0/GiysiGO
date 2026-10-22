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
            InactiveCategoryId = Guid.NewGuid(),
            InactiveCategoryCode = $"catalog-inactive-{Guid.NewGuid():N}",
            DeletedCategoryId = Guid.NewGuid(),
            DeletedCategoryCode = $"catalog-deleted-{Guid.NewGuid():N}",
            ProductTypeId = Guid.NewGuid(),
            ProductTypeCode = $"catalog-filter-{Guid.NewGuid():N}",
            InactiveProductTypeId = Guid.NewGuid(),
            InactiveProductTypeCode = $"catalog-inactive-{Guid.NewGuid():N}",
            DeletedProductTypeId = Guid.NewGuid(),
            DeletedProductTypeCode = $"catalog-deleted-{Guid.NewGuid():N}",
            ServiceId = Guid.NewGuid(),
            ServiceCode = $"catalog-filter-{Guid.NewGuid():N}",
            OtherServiceId = Guid.NewGuid(),
            OtherServiceCode = $"catalog-filter-{Guid.NewGuid():N}",
            InactiveServiceId = Guid.NewGuid(),
            InactiveServiceCode = $"catalog-inactive-{Guid.NewGuid():N}",
            DeletedServiceId = Guid.NewGuid(),
            DeletedServiceCode = $"catalog-deleted-{Guid.NewGuid():N}",
            CorporateId = Guid.NewGuid(),
            StoreId = Guid.NewGuid(),
            OtherStoreId = Guid.NewGuid(),
            InactiveStoreId = Guid.NewGuid(),
            DeletedStoreId = Guid.NewGuid(),
            OfferingId = Guid.NewGuid(),
            OtherStoreOfferingId = Guid.NewGuid(),
            UnmatchedOfferingId = Guid.NewGuid()
        };

        var fixtureCreated = false;
        Guid insertedCategoryId = Guid.Empty;
        Guid productTypeServiceId = Guid.Empty;
        Guid otherProductTypeServiceId = Guid.Empty;
        Guid inactiveProductTypeServiceId = Guid.Empty;
        Guid deletedProductTypeServiceId = Guid.Empty;

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

            var inactiveRelation = new ProductTypeService
            {
                ProductTypeId = fixture.ProductTypeId,
                ServiceId = fixture.InactiveServiceId,
                DefaultPrice = 35.00m,
                Currency = "TRY",
                PriceUnit = "PIECE",
                SelectionKind = "BASE",
                IsActive = false
            };
            inactiveProductTypeServiceId = await repository.AddProductTypeServiceAsync(inactiveRelation);

            var deletedRelation = new ProductTypeService
            {
                ProductTypeId = fixture.ProductTypeId,
                ServiceId = fixture.DeletedServiceId,
                DefaultPrice = 45.00m,
                Currency = "TRY",
                PriceUnit = "M2",
                SelectionKind = "BASE",
                IsActive = false
            };
            deletedProductTypeServiceId = await repository.AddProductTypeServiceAsync(deletedRelation);
            await repository.DeleteProductTypeServiceAsync(deletedProductTypeServiceId);

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
            Assert.DoesNotContain(categories, item => item.Id == fixture.InactiveCategoryId);
            Assert.DoesNotContain(categories, item => item.Id == fixture.DeletedCategoryId);
            var categoriesIncludingInactive = await repository.GetCategoriesAsync(includeInactive: true);
            Assert.Contains(categoriesIncludingInactive, item => item.Id == fixture.InactiveCategoryId);
            Assert.DoesNotContain(categoriesIncludingInactive, item => item.Id == fixture.DeletedCategoryId);
            Assert.NotNull(await repository.GetCategoryByIdAsync(fixture.CategoryId));
            Assert.Null(await repository.GetCategoryByIdAsync(fixture.DeletedCategoryId));

            insertedCategoryId = await repository.AddCategoryAsync(
                $"catalog-insert-{Guid.NewGuid():N}", "Catalog insert mapping test");
            Assert.Equal(insertedCategoryId, (await repository.GetCategoryByIdAsync(insertedCategoryId))?.Id);

            var pagedOverflowResult = await repository.GetProductTypesPagedAsync(
                fixture.CategoryId, int.MaxValue, 100);
            Assert.Empty(pagedOverflowResult);

            var productTypes = await repository.GetProductTypesAsync(fixture.CategoryId);
            Assert.Contains(productTypes, item => item.Id == fixture.ProductTypeId);
            Assert.DoesNotContain(productTypes, item => item.Id == fixture.InactiveProductTypeId);
            Assert.DoesNotContain(productTypes, item => item.Id == fixture.DeletedProductTypeId);
            var productTypesIncludingInactive = await repository.GetProductTypesAsync(
                fixture.CategoryId, includeInactive: true);
            Assert.Contains(productTypesIncludingInactive, item => item.Id == fixture.InactiveProductTypeId);
            Assert.DoesNotContain(productTypesIncludingInactive, item => item.Id == fixture.DeletedProductTypeId);
            Assert.Contains(await repository.GetProductTypesPagedAsync(fixture.CategoryId, 1, 10), item => item.Id == fixture.ProductTypeId);
            Assert.NotNull(await repository.GetProductTypeByIdAsync(fixture.ProductTypeId));

            var services = await repository.GetServicesAsync();
            Assert.Contains(services, item => item.Id == fixture.ServiceId);
            Assert.DoesNotContain(services, item => item.Id == fixture.InactiveServiceId);
            Assert.DoesNotContain(services, item => item.Id == fixture.DeletedServiceId);
            var servicesIncludingInactive = await repository.GetServicesAsync(includeInactive: true);
            Assert.Contains(servicesIncludingInactive, item => item.Id == fixture.InactiveServiceId);
            Assert.DoesNotContain(servicesIncludingInactive, item => item.Id == fixture.DeletedServiceId);
            Assert.NotNull(await repository.GetServiceByIdAsync(fixture.ServiceId));
            var stores = await repository.GetStoresAsync();
            Assert.Contains(stores, item => item.Id == fixture.StoreId);
            Assert.DoesNotContain(stores, item => item.Id == fixture.InactiveStoreId);
            Assert.DoesNotContain(stores, item => item.Id == fixture.DeletedStoreId);
            var storesIncludingInactive = await repository.GetStoresAsync(includeInactive: true);
            Assert.Contains(storesIncludingInactive, item => item.Id == fixture.InactiveStoreId);
            Assert.DoesNotContain(storesIncludingInactive, item => item.Id == fixture.DeletedStoreId);
            Assert.NotNull(await repository.GetStoreByIdAsync(fixture.StoreId));

            var relationById = await repository.GetProductTypeServiceByIdAsync(productTypeServiceId);
            Assert.NotNull(relationById);
            Assert.Equal(123.45m, relationById.DefaultPrice);
            Assert.Equal("PIECE", relationById.PriceUnit);
            Assert.Equal("ADD_ON", relationById.SelectionKind);
            Assert.Contains(await repository.GetProductTypeServicesAsync(fixture.ProductTypeId, fixture.ServiceId), item => item.Id == productTypeServiceId);
            var activeRelations = await repository.GetProductTypeServicesAsync(fixture.ProductTypeId);
            Assert.DoesNotContain(activeRelations, item => item.Id == inactiveProductTypeServiceId);
            Assert.DoesNotContain(activeRelations, item => item.Id == deletedProductTypeServiceId);
            var allRelations = await repository.GetProductTypeServicesAsync(fixture.ProductTypeId, includeInactive: true);
            Assert.Contains(allRelations, item => item.Id == inactiveProductTypeServiceId);
            Assert.DoesNotContain(allRelations, item => item.Id == deletedProductTypeServiceId);

            var storeOfferings = await repository.GetStoreOfferingsAsync(storeId: fixture.StoreId);
            Assert.Equal(2, storeOfferings.Count);
            Assert.Contains(storeOfferings, item => item.Id == fixture.OfferingId && item.ProductTypeServiceId == productTypeServiceId);
            Assert.Contains(storeOfferings, item => item.Id == fixture.UnmatchedOfferingId && item.ProductTypeServiceId == otherProductTypeServiceId);
            Assert.Equal(100.00m, storeOfferings.Single(item => item.Id == fixture.OfferingId).PriceOverride);
            Assert.Null(storeOfferings.Single(item => item.Id == fixture.UnmatchedOfferingId).PriceOverride);

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
                if (insertedCategoryId != Guid.Empty)
                    await ExecuteFixtureScriptAsync(connectionFactory, "DeleteInsertedCategory.sql", new { Id = insertedCategoryId });
            }
            finally
            {
                if (productTypeServiceId != Guid.Empty)
                    await repository.DeleteProductTypeServiceAsync(productTypeServiceId);
                if (otherProductTypeServiceId != Guid.Empty)
                    await repository.DeleteProductTypeServiceAsync(otherProductTypeServiceId);
                if (inactiveProductTypeServiceId != Guid.Empty)
                    await repository.DeleteProductTypeServiceAsync(inactiveProductTypeServiceId);
                if (deletedProductTypeServiceId != Guid.Empty)
                    await repository.DeleteProductTypeServiceAsync(deletedProductTypeServiceId);
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

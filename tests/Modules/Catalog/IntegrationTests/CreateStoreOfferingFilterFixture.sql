SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO [catalog].[product_categories] (id, code, name, sort_order, is_active)
VALUES (@CategoryId, @CategoryCode, N'Catalog filter test category', 0, 1);

INSERT INTO [catalog].[product_categories] (id, code, name, sort_order, is_active)
VALUES (@InactiveCategoryId, @InactiveCategoryCode, N'Catalog inactive test category', 1, 0);

INSERT INTO [catalog].[product_categories] (id, code, name, sort_order, is_active, delete_date)
VALUES (@DeletedCategoryId, @DeletedCategoryCode, N'Catalog deleted test category', 2, 0, SYSUTCDATETIME());

INSERT INTO [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
VALUES (@ProductTypeId, @CategoryId, @ProductTypeCode, N'Catalog filter test product', N'PIECE', 1);

INSERT INTO [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
VALUES (@InactiveProductTypeId, @CategoryId, @InactiveProductTypeCode, N'Catalog inactive test product', N'M2', 0);

INSERT INTO [catalog].[product_types] (id, category_id, code, name, base_unit, is_active, delete_date)
VALUES (@DeletedProductTypeId, @CategoryId, @DeletedProductTypeCode, N'Catalog deleted test product', N'PIECE', 0, SYSUTCDATETIME());

INSERT INTO [catalog].[services] (id, code, name, is_active)
VALUES (@ServiceId, @ServiceCode, N'Catalog filter test service', 1),
       (@OtherServiceId, @OtherServiceCode, N'Catalog filter test other service', 1);

INSERT INTO [catalog].[services] (id, code, name, is_active)
VALUES (@InactiveServiceId, @InactiveServiceCode, N'Catalog inactive test service', 0);

INSERT INTO [catalog].[services] (id, code, name, is_active, delete_date)
VALUES (@DeletedServiceId, @DeletedServiceCode, N'Catalog deleted test service', 0, SYSUTCDATETIME());

INSERT INTO [identity].[corporates] (id, name, is_active)
VALUES (@CorporateId, N'Catalog filter test corporate', 1);

INSERT INTO [catalog].[stores]
    (id, corporate_id, name, address_text, latitude, longitude, service_radius_km, is_active)
VALUES (@StoreId, @CorporateId, N'Catalog filter test store', N'Test address', 0, 0, 1, 1);

INSERT INTO [catalog].[stores]
    (id, corporate_id, name, address_text, latitude, longitude, service_radius_km, is_active)
VALUES (@OtherStoreId, @CorporateId, N'Catalog filter test other store', N'Test address', 0, 0, 1, 1);

INSERT INTO [catalog].[stores]
    (id, corporate_id, name, address_text, latitude, longitude, service_radius_km, is_active)
VALUES (@InactiveStoreId, @CorporateId, N'Catalog inactive test store', N'Test address', 0, 0, 1, 0);

INSERT INTO [catalog].[stores]
    (id, corporate_id, name, address_text, latitude, longitude, service_radius_km, is_active, delete_date)
VALUES (@DeletedStoreId, @CorporateId, N'Catalog deleted test store', N'Test address', 0, 0, 1, 0, SYSUTCDATETIME());

COMMIT TRANSACTION;

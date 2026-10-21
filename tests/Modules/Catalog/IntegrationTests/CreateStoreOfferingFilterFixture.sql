SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO [catalog].[product_categories] (id, code, name, sort_order, is_active)
VALUES (@CategoryId, @CategoryCode, N'Catalog filter test category', 0, 1);

INSERT INTO [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
VALUES (@ProductTypeId, @CategoryId, @ProductTypeCode, N'Catalog filter test product', N'PIECE', 1);

INSERT INTO [catalog].[services] (id, code, name, is_active)
VALUES (@ServiceId, @ServiceCode, N'Catalog filter test service', 1),
       (@OtherServiceId, @OtherServiceCode, N'Catalog filter test other service', 1);

INSERT INTO [identity].[corporates] (id, name, is_active)
VALUES (@CorporateId, N'Catalog filter test corporate', 1);

INSERT INTO [catalog].[stores]
    (id, corporate_id, name, address_text, latitude, longitude, service_radius_km, is_active)
VALUES (@StoreId, @CorporateId, N'Catalog filter test store', N'Test address', 0, 0, 1, 1);

INSERT INTO [catalog].[stores]
    (id, corporate_id, name, address_text, latitude, longitude, service_radius_km, is_active)
VALUES (@OtherStoreId, @CorporateId, N'Catalog filter test other store', N'Test address', 0, 0, 1, 1);

COMMIT TRANSACTION;

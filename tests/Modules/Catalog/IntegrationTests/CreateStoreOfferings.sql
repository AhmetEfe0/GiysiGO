SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO [catalog].[store_offerings] (id, store_id, product_type_service_id, price_override, is_active)
VALUES (@OfferingId, @StoreId, @ProductTypeServiceId, 100.00, 1),
       (@OtherStoreOfferingId, @OtherStoreId, @ProductTypeServiceId, 110.00, 1),
       (@UnmatchedOfferingId, @StoreId, @OtherProductTypeServiceId, NULL, 1);

COMMIT TRANSACTION;

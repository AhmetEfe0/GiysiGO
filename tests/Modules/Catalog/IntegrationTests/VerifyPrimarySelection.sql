SET NOCOUNT ON;
SET XACT_ABORT OFF;

DECLARE @CustomerId uniqueidentifier = NEWID(), @AddressId uniqueidentifier = NEWID(),
        @CorporateId uniqueidentifier = NEWID(), @StoreId uniqueidentifier = NEWID(),
        @CartId uniqueidentifier = NEWID(), @CartItemId uniqueidentifier = NEWID(),
        @PrimaryOfferingId uniqueidentifier = NEWID(), @AddOnOfferingId uniqueidentifier = NEWID();
DECLARE @ProductId uniqueidentifier = (SELECT id FROM catalog.product_types WHERE code = N'P006');
DECLARE @PrimaryPairId uniqueidentifier = (SELECT id FROM catalog.product_type_services WHERE product_type_id = @ProductId AND selection_kind = @PrimaryKind AND is_active = 1);
DECLARE @AddOnPairId uniqueidentifier = (SELECT pts.id FROM catalog.product_type_services pts JOIN catalog.services s ON s.id = pts.service_id WHERE pts.product_type_id = @ProductId AND s.code = N'S023');
IF @PrimaryPairId IS NULL OR @AddOnPairId IS NULL THROW 51101, N'Seçim testi için gerekli seed çiftleri yok.', 1;

INSERT [identity].users (id, email, password_hash) VALUES (@CustomerId, CONCAT(CONVERT(nvarchar(36), @CustomerId), N'@catalog-test.invalid'), N'test');
INSERT [identity].customer_addresses (id, user_id, label, address_text, latitude, longitude, contact_name, contact_phone)
VALUES (@AddressId, @CustomerId, N'Test', N'Test adresi', 41, 29, N'Test müşterisi', N'0000000000');
INSERT [identity].corporates (id, name) VALUES (@CorporateId, N'Katalog seçim testi');
INSERT catalog.stores (id, corporate_id, name, address_text, latitude, longitude, service_radius_km)
VALUES (@StoreId, @CorporateId, N'Test dükkânı', N'Test adresi', 41, 29, 10);
INSERT catalog.store_offerings (id, store_id, product_type_service_id)
VALUES (@PrimaryOfferingId, @StoreId, @PrimaryPairId), (@AddOnOfferingId, @StoreId, @AddOnPairId);
INSERT ordering.carts (id, customer_id, store_id, address_id, pickup_window_start, pickup_window_end)
VALUES (@CartId, @CustomerId, @StoreId, @AddressId, DATEADD(hour, 1, SYSUTCDATETIME()), DATEADD(hour, 2, SYSUTCDATETIME()));
INSERT ordering.cart_items (id, cart_id, product_type_id) VALUES (@CartItemId, @CartId, @ProductId);

-- Hiç hizmet seçilmemiş ürün kabul edilmez.
BEGIN TRY
    EXEC ordering.spCheckoutCart @CartId, @CustomerId, N'katalog-bos-secim', 0;
    THROW 51101, N'Hizmetsiz ürün yanlışlıkla kabul edildi.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51006 THROW;
END CATCH;

-- Yalnız ek hizmet seçimi de ürünü kabul ettirmez.
INSERT ordering.cart_item_services (id, cart_item_id, store_offering_id) VALUES (NEWID(), @CartItemId, @AddOnOfferingId);
BEGIN TRY
    EXEC ordering.spCheckoutCart @CartId, @CustomerId, N'katalog-yalniz-ek-hizmet', 0;
    THROW 51101, N'Yalnız ek hizmet içeren ürün yanlışlıkla kabul edildi.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51006 THROW;
END CATCH;

-- BASE veya ALTERNATIVE eklenince aynı ürün ve ek hizmet kabul edilir.
INSERT ordering.cart_item_services (id, cart_item_id, store_offering_id) VALUES (NEWID(), @CartItemId, @PrimaryOfferingId);
EXEC ordering.spCheckoutCart @CartId, @CustomerId, N'katalog-gecerli-secim', 0;
IF NOT EXISTS (SELECT 1 FROM ordering.carts WHERE id = @CartId AND status = N'CHECKED_OUT')
    THROW 51101, N'Geçerli ana hizmet seçimi kabul edilmedi.', 1;
IF (SELECT COUNT(*) FROM ordering.order_item_services ois JOIN ordering.order_items oi ON oi.id = ois.order_item_id JOIN ordering.orders o ON o.id = oi.order_id WHERE o.source_cart_id = @CartId) <> 2
    THROW 51101, N'Ana hizmet ve ek hizmet siparişe birlikte aktarılmadı.', 1;

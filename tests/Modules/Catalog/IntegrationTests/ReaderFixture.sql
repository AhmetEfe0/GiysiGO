IF @Operation = 'CREATE'
BEGIN
 INSERT [identity].corporates(id,name) VALUES (@CorporateId,N'Catalog reader test');
 INSERT catalog.stores(id,corporate_id,name,address_text,latitude,longitude,service_radius_km)
 VALUES (@StoreId,@CorporateId,N'Reader',N'Test adresi',41,29,5);
 INSERT catalog.product_categories(id,code,name) VALUES (@CategoryId,CONVERT(nvarchar(36),@CategoryId),N'Reader');
 INSERT catalog.product_types(id,category_id,code,name,base_unit) VALUES (@ProductId,@CategoryId,CONVERT(nvarchar(36),@ProductId),N'Reader','PIECE');
 INSERT catalog.services(id,code,name) VALUES (@ServiceId,CONVERT(nvarchar(36),@ServiceId),N'Reader');
 INSERT catalog.product_type_services(id,product_type_id,service_id,default_price,price_unit,selection_kind)
 VALUES (@PairId,@ProductId,@ServiceId,125.25,'PIECE','BASE');
 INSERT catalog.store_offerings(id,store_id,product_type_service_id) VALUES (@OfferingId,@StoreId,@PairId);
END;
IF @Operation = 'STATE'
BEGIN
 UPDATE [identity].corporates SET is_active=CASE WHEN @Target='corporate' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='corporate' AND @Deleted=1 THEN SYSUTCDATETIME() END WHERE id=@CorporateId;
 UPDATE catalog.stores SET is_active=CASE WHEN @Target='store' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='store' AND @Deleted=1 THEN SYSUTCDATETIME() END,
  latitude=41,longitude=29,service_radius_km=5 WHERE id=@StoreId;
 UPDATE catalog.product_categories SET is_active=CASE WHEN @Target='category' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='category' AND @Deleted=1 THEN SYSUTCDATETIME() END WHERE id=@CategoryId;
 UPDATE catalog.product_types SET is_active=CASE WHEN @Target='product' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='product' AND @Deleted=1 THEN SYSUTCDATETIME() END WHERE id=@ProductId;
 UPDATE catalog.services SET is_active=CASE WHEN @Target='service' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='service' AND @Deleted=1 THEN SYSUTCDATETIME() END WHERE id=@ServiceId;
 UPDATE catalog.product_type_services SET is_active=CASE WHEN @Target='pair' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='pair' AND @Deleted=1 THEN SYSUTCDATETIME() END,
  default_price=125.25,price_unit=@PriceUnit WHERE id=@PairId;
 UPDATE catalog.store_offerings SET is_active=CASE WHEN @Target='offering' AND @Deleted=0 THEN 0 ELSE 1 END,
  delete_date=CASE WHEN @Target='offering' AND @Deleted=1 THEN SYSUTCDATETIME() END,
  price_override=@PriceOverride WHERE id=@OfferingId;
END;
IF @Operation = 'CHANGE'
BEGIN
 SET LOCK_TIMEOUT 1000;
 IF @Target='price' UPDATE catalog.product_type_services SET default_price=199.99 WHERE id=@PairId;
 IF @Target='override' UPDATE catalog.store_offerings SET price_override=149.50 WHERE id=@OfferingId;
 IF @Target='offering' UPDATE catalog.store_offerings SET is_active=0 WHERE id=@OfferingId;
 IF @Target='pair' UPDATE catalog.product_type_services SET is_active=0 WHERE id=@PairId;
 IF @Target='product' UPDATE catalog.product_types SET is_active=0 WHERE id=@ProductId;
 IF @Target='category' UPDATE catalog.product_categories SET is_active=0 WHERE id=@CategoryId;
 IF @Target='service' UPDATE catalog.services SET is_active=0 WHERE id=@ServiceId;
 IF @Target='store' UPDATE catalog.stores SET is_active=0 WHERE id=@StoreId;
 IF @Target='corporate' UPDATE [identity].corporates SET is_active=0 WHERE id=@CorporateId;
 IF @Target='radius' UPDATE catalog.stores SET service_radius_km=1 WHERE id=@StoreId;
 IF @Target='location' UPDATE catalog.stores SET latitude=42,address_text=N'Yeni adres' WHERE id=@StoreId;
END;
IF @Operation = 'DELETE'
BEGIN
 DELETE FROM catalog.store_offerings WHERE id=@OfferingId;
 DELETE FROM catalog.product_type_services WHERE id=@PairId;
 DELETE FROM catalog.services WHERE id=@ServiceId;
 DELETE FROM catalog.product_types WHERE id=@ProductId;
 DELETE FROM catalog.product_categories WHERE id=@CategoryId;
 DELETE FROM catalog.stores WHERE id=@StoreId;
 DELETE FROM [identity].corporates WHERE id=@CorporateId;
END;

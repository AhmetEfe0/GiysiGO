IF @Operation = 'CREATE'
BEGIN
    INSERT catalog.product_categories(id,code,name) VALUES (@CategoryId,CONVERT(nvarchar(36),@CategoryId),N'Okuyucu kategorisi');
    INSERT catalog.product_types(id,category_id,code,name,base_unit) VALUES (@ProductId,@CategoryId,CONVERT(nvarchar(36),@ProductId),N'Okuyucu ürünü','PIECE');
    INSERT catalog.services(id,code,name) VALUES (@ServiceId,CONVERT(nvarchar(36),@ServiceId),N'Okuyucu hizmeti');
    INSERT catalog.product_type_services(id,product_type_id,service_id,default_price,price_unit,selection_kind)
        VALUES (@PairId,@ProductId,@ServiceId,125.25,'PIECE','BASE');
    INSERT catalog.store_offerings(id,store_id,product_type_service_id) VALUES (@OfferingId,@StoreId,@PairId);
END;
IF @Operation = 'CHANGE'
BEGIN
    UPDATE catalog.store_offerings SET price_override = @PriceOverride, is_active = CASE WHEN @Hidden = 'offering' THEN 0 ELSE 1 END WHERE id = @OfferingId;
    UPDATE catalog.product_type_services SET is_active = CASE WHEN @Hidden = 'pair' THEN 0 ELSE 1 END WHERE id = @PairId;
    UPDATE catalog.product_types SET is_active = CASE WHEN @Hidden = 'product' THEN 0 ELSE 1 END WHERE id = @ProductId;
    UPDATE catalog.services SET is_active = CASE WHEN @Hidden = 'service' THEN 0 ELSE 1 END WHERE id = @ServiceId;
    UPDATE catalog.product_categories SET is_active = CASE WHEN @Hidden = 'category' THEN 0 ELSE 1 END WHERE id = @CategoryId;
END;
IF @Operation = 'DELETE'
BEGIN
    DELETE catalog.store_offerings WHERE id = @OfferingId;
    DELETE catalog.product_type_services WHERE id = @PairId;
    DELETE catalog.product_types WHERE id = @ProductId;
    DELETE catalog.services WHERE id = @ServiceId;
    DELETE catalog.product_categories WHERE id = @CategoryId;
END;

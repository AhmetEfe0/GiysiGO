SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF @Operation = 'CREATE'
BEGIN
    INSERT [identity].customer_addresses(id,user_id,label,address_text,latitude,longitude,contact_name,contact_phone)
    VALUES (@AddressId,@UserId,N'Test',N'Test',41,29,N'Test',N'000');
    INSERT ordering.carts(id,customer_id,store_id,address_id,status) VALUES (@CartId,@UserId,@StoreId,@AddressId,'CHECKED_OUT');
    INSERT ordering.orders(id,source_cart_id,customer_id,store_id,pickup_window_start,pickup_window_end,estimated_total,idempotency_key)
    VALUES (@OrderId,@CartId,@UserId,@StoreId,SYSUTCDATETIME(),DATEADD(hour,1,SYSUTCDATETIME()),125.25,CONVERT(nvarchar(36),@OrderId));
    INSERT ordering.order_items(id,order_id,product_type_id,product_type_name_snapshot,tracking_code)
    VALUES (@ItemId,@OrderId,@ProductId,N'Eski ürün',CONVERT(nvarchar(36),@ItemId));
    INSERT ordering.order_item_services(id,order_item_id,product_type_service_id,service_name_snapshot,estimated_unit_price,price_unit_snapshot,estimated_quantity,estimated_price)
    VALUES (@ItemServiceId,@ItemId,@PairId,N'Eski hizmet',125.25,'PIECE',1,125.25);
    INSERT ordering.price_quotes(id,order_id,revision,status,total_amount) VALUES (@QuoteId,@OrderId,1,'PUBLISHED',125.25);
    INSERT ordering.price_quote_lines(id,price_quote_id,order_item_service_id,service_name_snapshot,unit_price,price_unit,quantity,amount)
    VALUES (@LineId,@QuoteId,@ItemServiceId,N'Eski hizmet',125.25,'PIECE',1,125.25);
END;
IF @Operation = 'VERIFY'
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ordering.order_item_services WHERE id = @ItemServiceId AND estimated_unit_price = 125.25 AND estimated_price = 125.25 AND price_unit_snapshot = 'PIECE')
        THROW 52410, N'Sipariş fiyat snapshot değişti.', 1;
    IF NOT EXISTS (SELECT 1 FROM ordering.price_quote_lines WHERE id = @LineId AND unit_price = 125.25 AND amount = 125.25 AND price_unit = 'PIECE')
        THROW 52410, N'Teklif fiyat snapshot değişti.', 1;
END;
IF @Operation = 'DELETE'
BEGIN
    DELETE ordering.price_quote_lines WHERE id = @LineId;
    DELETE ordering.price_quotes WHERE id = @QuoteId;
    DELETE ordering.order_item_services WHERE id = @ItemServiceId;
    DELETE ordering.order_items WHERE id = @ItemId;
    DELETE ordering.orders WHERE id = @OrderId;
    DELETE ordering.carts WHERE id = @CartId;
    DELETE [identity].customer_addresses WHERE id = @AddressId;
END;
COMMIT;

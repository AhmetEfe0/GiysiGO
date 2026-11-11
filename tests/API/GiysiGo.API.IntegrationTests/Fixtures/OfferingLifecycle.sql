UPDATE catalog.stores SET is_active = @StoreActive WHERE id = @StoreId;
UPDATE [identity].corporates SET is_active = @CorporateActive WHERE id = @CorporateId;

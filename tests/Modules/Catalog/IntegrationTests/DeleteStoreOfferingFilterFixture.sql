SET XACT_ABORT ON;
BEGIN TRANSACTION;

UPDATE [catalog].[store_offerings]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id IN (@OfferingId, @OtherStoreOfferingId, @UnmatchedOfferingId);

UPDATE [catalog].[stores]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id IN (@StoreId, @OtherStoreId, @InactiveStoreId, @DeletedStoreId);

UPDATE [identity].[corporates]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id = @CorporateId;

UPDATE [catalog].[services]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id IN (@ServiceId, @OtherServiceId);
UPDATE [catalog].[services]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id IN (@InactiveServiceId, @DeletedServiceId);

UPDATE [catalog].[product_types]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id = @ProductTypeId;
UPDATE [catalog].[product_types]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id IN (@InactiveProductTypeId, @DeletedProductTypeId);

UPDATE [catalog].[product_categories]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id = @CategoryId;
UPDATE [catalog].[product_categories]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id IN (@InactiveCategoryId, @DeletedCategoryId);

COMMIT TRANSACTION;

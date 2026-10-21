CREATE PROCEDURE [catalog].[usp_GetStoreOfferings]
    @store_id UNIQUEIDENTIFIER = NULL,
    @product_type_service_id UNIQUEIDENTIFIER = NULL,
    @include_inactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id AS Id, store_id AS StoreId,
           product_type_service_id AS ProductTypeServiceId,
           price_override AS PriceOverride, is_active AS IsActive,
           create_date AS CreateDate, update_date AS UpdateDate,
           delete_date AS DeleteDate
    FROM [catalog].[store_offerings]
    WHERE delete_date IS NULL
      AND (@store_id IS NULL OR store_id = @store_id)
      AND (@product_type_service_id IS NULL OR product_type_service_id = @product_type_service_id)
      AND (@include_inactive = 1 OR is_active = 1)
    ORDER BY store_id, product_type_service_id, id;
END
GO

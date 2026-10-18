CREATE PROCEDURE [catalog].[usp_GetStoreOfferings]
    @store_id UNIQUEIDENTIFIER,
    @include_inactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id] AS Id,
        [store_id] AS StoreId,
        [product_type_service_id] AS ProductTypeServiceId,
        [price_override] AS PriceOverride,
        [is_active] AS IsActive,
        [create_date] AS CreateDate,
        [update_date] AS UpdateDate,
        [delete_date] AS DeleteDate
    FROM [catalog].[store_offerings]
    WHERE [store_id] = @store_id
      AND [delete_date] IS NULL
      AND (@include_inactive = 1 OR [is_active] = 1)
    ORDER BY [id] ASC;
END
GO
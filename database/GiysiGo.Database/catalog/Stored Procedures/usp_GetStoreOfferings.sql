CREATE PROCEDURE [catalog].[usp_GetStoreOfferings]
    @store_id UNIQUEIDENTIFIER = NULL,
    @product_type_service_id UNIQUEIDENTIFIER = NULL,
    @include_inactive BIT = 0,
    @page_number INT = 1,
    @page_size INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    IF @page_number < 1 SET @page_number = 1;
    IF @page_size < 1 SET @page_size = 50;
    IF @page_size > 100 SET @page_size = 100;

    DECLARE @offset BIGINT = (CONVERT(BIGINT, @page_number) - 1) * CONVERT(BIGINT, @page_size);

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
    ORDER BY store_id, product_type_service_id, id
    OFFSET @offset ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO

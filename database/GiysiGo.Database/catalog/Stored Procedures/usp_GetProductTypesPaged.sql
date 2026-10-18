CREATE PROCEDURE [catalog].[usp_GetProductTypesPaged]
    @category_id UNIQUEIDENTIFIER = NULL,
    @include_inactive BIT = 0,
    @page_number INT = 1,
    @page_size INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @page_number < 1 SET @page_number = 1;
    IF @page_size < 1 SET @page_size = 20;
    IF @page_size > 100 SET @page_size = 100;

    DECLARE @offset INT = (@page_number - 1) * @page_size;

    SELECT
        [id] AS Id,
        [category_id] AS CategoryId,
        [code] AS Code,
        [name] AS Name,
        [base_unit] AS BaseUnit,
        [is_active] AS IsActive,
        [create_date] AS CreateDate,
        [update_date] AS UpdateDate,
        [delete_date] AS DeleteDate
    FROM [catalog].[product_types]
    WHERE [delete_date] IS NULL
      AND (@include_inactive = 1 OR [is_active] = 1)
      AND (@category_id IS NULL OR [category_id] = @category_id)
    ORDER BY [name] ASC, [id] ASC
    OFFSET @offset ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO
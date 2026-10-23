CREATE PROCEDURE [catalog].[usp_GetProductTypes]
    @CategoryId UNIQUEIDENTIFIER = NULL,
    @IncludeInactive BIT = 0,
    @page_number INT = 1,
    @page_size INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    IF @page_number < 1 SET @page_number = 1;
    IF @page_size < 1 SET @page_size = 50;
    IF @page_size > 100 SET @page_size = 100;

    DECLARE @offset BIGINT = (CONVERT(BIGINT, @page_number) - 1) * CONVERT(BIGINT, @page_size);

    SELECT id AS Id, category_id AS CategoryId, code AS Code, name AS Name,
           base_unit AS BaseUnit, is_active AS IsActive,
           create_date AS CreateDate, update_date AS UpdateDate,
           delete_date AS DeleteDate
    FROM [catalog].[product_types]
    WHERE delete_date IS NULL
      AND (@IncludeInactive = 1 OR is_active = 1)
      AND (@CategoryId IS NULL OR category_id = @CategoryId)
    ORDER BY name, id
    OFFSET @offset ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO

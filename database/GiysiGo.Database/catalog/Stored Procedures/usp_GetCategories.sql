CREATE PROCEDURE [catalog].[usp_GetCategories]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id] AS Id,
        [code] AS Code,
        [name] AS Name,
        [sort_order] AS SortOrder,
        [is_active] AS IsActive,
        [create_date] AS CreateDate,
        [update_date] AS UpdateDate,
        [delete_date] AS DeleteDate
    FROM [catalog].[product_categories]
    WHERE [delete_date] IS NULL
      AND (@IncludeInactive = 1 OR [is_active] = 1)
    ORDER BY [sort_order] ASC, [name] ASC;
END
GO

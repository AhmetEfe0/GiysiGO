CREATE PROCEDURE [catalog].[usp_GetProductTypes]
    @CategoryId UNIQUEIDENTIFIER = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id AS Id, category_id AS CategoryId, code AS Code, name AS Name,
           base_unit AS BaseUnit, is_active AS IsActive,
           create_date AS CreateDate, update_date AS UpdateDate,
           delete_date AS DeleteDate
    FROM [catalog].[product_types]
    WHERE delete_date IS NULL
      AND (@IncludeInactive = 1 OR is_active = 1)
      AND (@CategoryId IS NULL OR category_id = @CategoryId)
    ORDER BY name, id;
END
GO

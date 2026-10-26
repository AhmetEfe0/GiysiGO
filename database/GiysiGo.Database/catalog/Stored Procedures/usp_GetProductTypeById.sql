CREATE PROCEDURE [catalog].[usp_GetProductTypeById]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id AS Id, category_id AS CategoryId, code AS Code, name AS Name,
           base_unit AS BaseUnit, is_active AS IsActive,
           create_date AS CreateDate, update_date AS UpdateDate,
           delete_date AS DeleteDate
    FROM [catalog].[product_types]
    WHERE id = @Id AND delete_date IS NULL;
END
GO

CREATE PROCEDURE [catalog].[usp_GetServiceById]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id AS Id, code AS Code, name AS Name, is_active AS IsActive,
           create_date AS CreateDate, update_date AS UpdateDate,
           delete_date AS DeleteDate
    FROM [catalog].[services]
    WHERE id = @Id AND delete_date IS NULL;
END
GO

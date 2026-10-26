CREATE PROCEDURE [catalog].[usp_DeleteProductTypeService]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [catalog].[product_type_services]
    SET delete_date = SYSUTCDATETIME(), update_date = SYSUTCDATETIME(),
        is_active = 0, is_default_selected = 0
    WHERE id = @Id AND delete_date IS NULL;
END
GO

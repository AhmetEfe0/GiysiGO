CREATE PROCEDURE [catalog].[usp_InsertCategory]
    @id UNIQUEIDENTIFIER,
    @code NVARCHAR(100),
    @name NVARCHAR(200),
    @sort_order INT = 0,
    @is_active BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [catalog].[product_categories] (
        [id],
        [code],
        [name],
        [sort_order],
        [is_active],
        [create_date]
    )
    OUTPUT inserted.id
    VALUES (
        @id,
        @code,
        @name,
        @sort_order,
        @is_active,
        SYSUTCDATETIME()
    );
END
GO
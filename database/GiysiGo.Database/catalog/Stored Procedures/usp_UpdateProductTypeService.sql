CREATE PROCEDURE [catalog].[usp_UpdateProductTypeService]
    @Id UNIQUEIDENTIFIER,
    @ProductTypeId UNIQUEIDENTIFIER,
    @ServiceId UNIQUEIDENTIFIER,
    @DefaultPrice DECIMAL(12,2),
    @Currency CHAR(3),
    @PriceUnit NVARCHAR(20),
    @SelectionKind NVARCHAR(30),
    @IsDefaultSelected BIT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    IF @IsDefaultSelected = 1
        UPDATE [catalog].[product_type_services]
        SET is_default_selected = 0, update_date = SYSUTCDATETIME()
        WHERE product_type_id = @ProductTypeId AND is_default_selected = 1;
    UPDATE [catalog].[product_type_services]
    SET product_type_id = @ProductTypeId, service_id = @ServiceId,
        default_price = @DefaultPrice, currency = @Currency,
        price_unit = @PriceUnit, selection_kind = @SelectionKind,
        is_default_selected = @IsDefaultSelected, is_active = @IsActive,
        update_date = SYSUTCDATETIME()
    WHERE id = @Id AND delete_date IS NULL;
    IF @@ROWCOUNT = 0 THROW 51000, 'Product type service was not found.', 1;
    COMMIT TRANSACTION;
END
GO

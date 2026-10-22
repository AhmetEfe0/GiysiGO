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

    DECLARE @ExistingProductTypeId UNIQUEIDENTIFIER;
    DECLARE @ExistingServiceId UNIQUEIDENTIFIER;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @ExistingProductTypeId = product_type_id,
            @ExistingServiceId = service_id
        FROM [catalog].[product_type_services] WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @Id AND delete_date IS NULL;

        IF @ExistingProductTypeId IS NULL
            THROW 51000, 'Product type service was not found.', 1;

        IF @ExistingProductTypeId <> @ProductTypeId OR @ExistingServiceId <> @ServiceId
            THROW 51002, 'Product type and service cannot be changed for an existing relation.', 1;

        IF @IsDefaultSelected = 1
            UPDATE [catalog].[product_type_services]
            SET is_default_selected = 0, update_date = SYSUTCDATETIME()
            WHERE product_type_id = @ExistingProductTypeId
              AND id <> @Id
              AND is_default_selected = 1
              AND delete_date IS NULL;

        UPDATE [catalog].[product_type_services]
        SET default_price = @DefaultPrice,
            currency = @Currency,
            price_unit = @PriceUnit,
            selection_kind = @SelectionKind,
            is_default_selected = @IsDefaultSelected,
            is_active = @IsActive,
            update_date = SYSUTCDATETIME()
        WHERE id = @Id AND delete_date IS NULL;

        IF @@ROWCOUNT = 0
            THROW 51000, 'Product type service was not found.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

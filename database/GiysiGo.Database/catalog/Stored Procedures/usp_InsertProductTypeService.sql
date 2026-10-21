CREATE PROCEDURE [catalog].[usp_InsertProductTypeService]
    @Id UNIQUEIDENTIFIER = NULL,
    @ProductTypeId UNIQUEIDENTIFIER,
    @ServiceId UNIQUEIDENTIFIER,
    @DefaultPrice DECIMAL(12,2),
    @Currency CHAR(3) = 'TRY',
    @PriceUnit NVARCHAR(20),
    @SelectionKind NVARCHAR(30),
    @IsDefaultSelected BIT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId UNIQUEIDENTIFIER = COALESCE(NULLIF(@Id, '00000000-0000-0000-0000-000000000000'), NEWID());
    DECLARE @ExistingId UNIQUEIDENTIFIER;

    BEGIN TRANSACTION;

    SELECT @ExistingId = id
    FROM [catalog].[product_type_services] WITH (UPDLOCK, HOLDLOCK)
    WHERE product_type_id = @ProductTypeId AND service_id = @ServiceId;

    IF @ExistingId IS NOT NULL
       AND EXISTS (
           SELECT 1
           FROM [catalog].[product_type_services]
           WHERE id = @ExistingId AND delete_date IS NULL
       )
        THROW 51001, 'Product type service already exists.', 1;

    IF @IsDefaultSelected = 1
        UPDATE [catalog].[product_type_services]
        SET is_default_selected = 0, update_date = SYSUTCDATETIME()
        WHERE product_type_id = @ProductTypeId AND is_default_selected = 1;

    IF @ExistingId IS NOT NULL
    BEGIN
        UPDATE [catalog].[product_type_services]
        SET default_price = @DefaultPrice,
            currency = @Currency,
            price_unit = @PriceUnit,
            selection_kind = @SelectionKind,
            is_default_selected = @IsDefaultSelected,
            is_active = @IsActive,
            delete_date = NULL,
            update_date = SYSUTCDATETIME()
        WHERE id = @ExistingId;

        SET @NewId = @ExistingId;
    END
    ELSE
    BEGIN
        INSERT [catalog].[product_type_services]
            (id, product_type_id, service_id, default_price, currency, price_unit,
             selection_kind, is_default_selected, is_active)
        VALUES
            (@NewId, @ProductTypeId, @ServiceId, @DefaultPrice, @Currency, @PriceUnit,
             @SelectionKind, @IsDefaultSelected, @IsActive);
    END

    COMMIT TRANSACTION;
    SELECT @NewId AS Id;
END
GO

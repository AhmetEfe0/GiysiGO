CREATE PROCEDURE [catalog].[usp_ManageProductTypeService]
    @Operation nvarchar(10), @Id uniqueidentifier,
    @ProductTypeId uniqueidentifier = NULL, @ServiceId uniqueidentifier = NULL,
    @DefaultPrice decimal(12,2) = 0, @PriceUnit nvarchar(20) = N'PIECE',
    @SelectionKind nvarchar(30) = N'BASE', @IsActive bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Operation NOT IN (N'CREATE', N'UPDATE', N'DELETE') OR @Id IS NULL OR @Id = '00000000-0000-0000-0000-000000000000'
        THROW 52200, N'Geçersiz katalog yönetimi isteği.', 1;
    IF @Operation <> N'DELETE' AND (@DefaultPrice IS NULL OR @DefaultPrice < 0 OR @PriceUnit IS NULL OR @PriceUnit NOT IN (N'PIECE', N'M2') OR @SelectionKind IS NULL OR @SelectionKind NOT IN (N'BASE', N'ALTERNATIVE', N'ADD_ON'))
        THROW 52200, N'Fiyat, birim veya seçim türü geçersiz.', 1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Operation <> N'DELETE' AND (
            NOT EXISTS (SELECT 1 FROM catalog.product_categories c WITH (UPDLOCK, HOLDLOCK) JOIN catalog.product_types pt WITH (UPDLOCK, HOLDLOCK) ON pt.category_id = c.id WHERE pt.id = @ProductTypeId AND pt.delete_date IS NULL AND c.delete_date IS NULL AND (@IsActive = 0 OR (pt.is_active = 1 AND c.is_active = 1)))
            OR NOT EXISTS (SELECT 1 FROM catalog.services WITH (UPDLOCK, HOLDLOCK) WHERE id = @ServiceId AND delete_date IS NULL AND (@IsActive = 0 OR is_active = 1))
        ) THROW 52201, N'Uygun ürün veya hizmet bulunamadı.', 1;
        IF @Operation <> N'CREATE' AND NOT EXISTS (SELECT 1 FROM catalog.product_type_services WITH (UPDLOCK, HOLDLOCK) WHERE id = @Id AND delete_date IS NULL)
            THROW 52201, N'Ürün/hizmet çifti bulunamadı.', 1;
        IF @Operation = N'UPDATE' AND EXISTS (SELECT 1 FROM catalog.product_type_services WHERE id = @Id AND (product_type_id <> @ProductTypeId OR service_id <> @ServiceId))
            THROW 52202, N'Çiftin ürün ve hizmet kimlikleri değiştirilemez.', 1;
        IF @Operation = N'CREATE'
            INSERT catalog.product_type_services (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
            VALUES (@Id, @ProductTypeId, @ServiceId, @DefaultPrice, 'TRY', @PriceUnit, @SelectionKind, 0, @IsActive);
        ELSE IF @Operation = N'UPDATE'
            UPDATE catalog.product_type_services SET default_price = @DefaultPrice, price_unit = @PriceUnit, selection_kind = @SelectionKind, is_active = @IsActive, is_default_selected = 0, update_date = SYSUTCDATETIME() WHERE id = @Id;
        ELSE
            UPDATE catalog.product_type_services SET is_active = 0, is_default_selected = 0, delete_date = SYSUTCDATETIME(), update_date = SYSUTCDATETIME() WHERE id = @Id;
        COMMIT TRANSACTION;
        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [catalog].[usp_ManageProductType]
    @Operation nvarchar(10), @Id uniqueidentifier,
    @CategoryId uniqueidentifier = NULL, @Code nvarchar(100) = NULL,
    @Name nvarchar(200) = NULL, @BaseUnit nvarchar(20) = N'PIECE', @IsActive bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Operation NOT IN (N'CREATE', N'UPDATE', N'DELETE') OR @Id IS NULL OR @Id = '00000000-0000-0000-0000-000000000000'
        THROW 52200, N'Geçersiz katalog yönetimi isteği.', 1;
    IF @Operation <> N'DELETE' AND (NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Name)), N'') IS NULL OR @BaseUnit IS NULL OR @BaseUnit NOT IN (N'PIECE', N'M2'))
        THROW 52200, N'Kod, ad veya birim geçersiz.', 1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Operation <> N'DELETE' AND NOT EXISTS (SELECT 1 FROM catalog.product_categories WITH (UPDLOCK, HOLDLOCK) WHERE id = @CategoryId AND delete_date IS NULL AND (@IsActive = 0 OR is_active = 1))
            THROW 52201, N'Uygun kategori bulunamadı.', 1;
        IF @Operation <> N'CREATE' AND NOT EXISTS (SELECT 1 FROM catalog.product_types WITH (UPDLOCK, HOLDLOCK) WHERE id = @Id AND delete_date IS NULL)
            THROW 52201, N'Ürün tipi bulunamadı.', 1;
        IF @Operation = N'UPDATE' AND EXISTS (SELECT 1 FROM catalog.product_types WHERE id = @Id AND code <> LTRIM(RTRIM(@Code)))
            THROW 52202, N'Sabit ürün kodu değiştirilemez.', 1;
        IF @Operation = N'CREATE'
            INSERT catalog.product_types (id, category_id, code, name, base_unit, is_active) VALUES (@Id, @CategoryId, LTRIM(RTRIM(@Code)), LTRIM(RTRIM(@Name)), @BaseUnit, @IsActive);
        ELSE IF @Operation = N'UPDATE'
            UPDATE catalog.product_types SET category_id = @CategoryId, name = LTRIM(RTRIM(@Name)), base_unit = @BaseUnit, is_active = @IsActive, update_date = SYSUTCDATETIME() WHERE id = @Id;
        ELSE
            UPDATE catalog.product_types SET is_active = 0, delete_date = SYSUTCDATETIME(), update_date = SYSUTCDATETIME() WHERE id = @Id;
        COMMIT TRANSACTION;
        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

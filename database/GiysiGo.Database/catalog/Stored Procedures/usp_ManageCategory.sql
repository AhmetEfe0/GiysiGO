CREATE PROCEDURE [catalog].[usp_ManageCategory]
    @Operation nvarchar(10), @Id uniqueidentifier,
    @Code nvarchar(100) = NULL, @Name nvarchar(200) = NULL,
    @SortOrder int = 0, @IsActive bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Operation NOT IN (N'CREATE', N'UPDATE', N'DELETE') OR @Id IS NULL OR @Id = '00000000-0000-0000-0000-000000000000'
        THROW 52200, N'Geçersiz katalog yönetimi isteği.', 1;
    IF @Operation <> N'DELETE' AND (NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Name)), N'') IS NULL OR @SortOrder < 0)
        THROW 52200, N'Kod, ad ve sıralama bilgileri geçersiz.', 1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Operation <> N'CREATE' AND NOT EXISTS (SELECT 1 FROM catalog.product_categories WITH (UPDLOCK, HOLDLOCK) WHERE id = @Id AND delete_date IS NULL)
            THROW 52201, N'Kategori bulunamadı.', 1;
        IF (@Operation = N'DELETE' OR @IsActive = 0) AND EXISTS (SELECT 1 FROM catalog.product_types WITH (UPDLOCK, HOLDLOCK) WHERE category_id = @Id AND is_active = 1 AND delete_date IS NULL)
            THROW 52202, N'Aktif ürünleri bulunan kategori pasifleştirilemez.', 1;
        IF @Operation = N'UPDATE' AND EXISTS (SELECT 1 FROM catalog.product_categories WHERE id = @Id AND code <> LTRIM(RTRIM(@Code)))
            THROW 52202, N'Sabit kategori kodu değiştirilemez.', 1;
        IF @Operation = N'CREATE'
            INSERT catalog.product_categories (id, code, name, sort_order, is_active) VALUES (@Id, LTRIM(RTRIM(@Code)), LTRIM(RTRIM(@Name)), @SortOrder, @IsActive);
        ELSE IF @Operation = N'UPDATE'
            UPDATE catalog.product_categories SET name = LTRIM(RTRIM(@Name)), sort_order = @SortOrder, is_active = @IsActive, update_date = SYSUTCDATETIME() WHERE id = @Id;
        ELSE
            UPDATE catalog.product_categories SET is_active = 0, delete_date = SYSUTCDATETIME(), update_date = SYSUTCDATETIME() WHERE id = @Id;
        COMMIT TRANSACTION;
        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

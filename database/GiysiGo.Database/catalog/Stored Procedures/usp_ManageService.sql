CREATE PROCEDURE [catalog].[usp_ManageService]
    @Operation nvarchar(10), @Id uniqueidentifier,
    @Code nvarchar(100) = NULL, @Name nvarchar(200) = NULL, @IsActive bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Operation NOT IN (N'CREATE', N'UPDATE', N'DELETE') OR @Id IS NULL OR @Id = '00000000-0000-0000-0000-000000000000'
        THROW 52200, N'Geçersiz katalog yönetimi isteği.', 1;
    IF @Operation <> N'DELETE' AND (NULLIF(LTRIM(RTRIM(@Code)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Name)), N'') IS NULL)
        THROW 52200, N'Kod ve ad boş olamaz.', 1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Operation <> N'CREATE' AND NOT EXISTS (SELECT 1 FROM catalog.services WITH (UPDLOCK, HOLDLOCK) WHERE id = @Id AND delete_date IS NULL)
            THROW 52201, N'Hizmet bulunamadı.', 1;
        IF @Operation = N'UPDATE' AND EXISTS (SELECT 1 FROM catalog.services WHERE id = @Id AND code <> LTRIM(RTRIM(@Code)))
            THROW 52202, N'Sabit hizmet kodu değiştirilemez.', 1;
        IF @Operation = N'CREATE'
            INSERT catalog.services (id, code, name, is_active) VALUES (@Id, LTRIM(RTRIM(@Code)), LTRIM(RTRIM(@Name)), @IsActive);
        ELSE IF @Operation = N'UPDATE'
            UPDATE catalog.services SET name = LTRIM(RTRIM(@Name)), is_active = @IsActive, update_date = SYSUTCDATETIME() WHERE id = @Id;
        ELSE
            UPDATE catalog.services SET is_active = 0, delete_date = SYSUTCDATETIME(), update_date = SYSUTCDATETIME() WHERE id = @Id;
        COMMIT TRANSACTION;
        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [catalog].[usp_ManageStore]
    @Operation nvarchar(30), @CorporateId uniqueidentifier, @Id uniqueidentifier,
    @Name nvarchar(max) = NULL, @AddressText nvarchar(max) = NULL,
    @Latitude decimal(38,28) = NULL, @Longitude decimal(38,28) = NULL,
    @ServiceRadiusKm decimal(38,28) = NULL, @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @CorporateId IS NULL OR @Id IS NULL OR @CorporateId = '00000000-0000-0000-0000-000000000000'
        OR @Id = '00000000-0000-0000-0000-000000000000' OR @Operation IS NULL OR @Operation NOT IN ('CREATE','UPDATE','SET_ACTIVE')
        THROW 52300, N'Dükkân komutu veya kimlik geçersiz.', 1;
    IF @Operation IN ('CREATE','UPDATE') AND (
        @Name IS NULL OR LEN(TRIM(@Name)) = 0 OR DATALENGTH(@Name) > 400
        OR @AddressText IS NULL OR LEN(TRIM(@AddressText)) = 0 OR DATALENGTH(@AddressText) > 4000
        OR @Latitude IS NULL OR @Latitude NOT BETWEEN -90 AND 90 OR ROUND(@Latitude,6) <> @Latitude
        OR @Longitude IS NULL OR @Longitude NOT BETWEEN -180 AND 180 OR ROUND(@Longitude,6) <> @Longitude
        OR @ServiceRadiusKm IS NULL OR @ServiceRadiusKm <= 0 OR @ServiceRadiusKm > 99999.99 OR ROUND(@ServiceRadiusKm,2) <> @ServiceRadiusKm)
        THROW 52300, N'Dükkân adı, adresi, koordinatı veya hizmet yarıçapı geçersiz.', 1;
    IF @Operation = 'SET_ACTIVE' AND @IsActive IS NULL
        THROW 52300, N'Aktiflik bilgisi zorunludur.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Operation = 'CREATE'
        BEGIN
            IF EXISTS (SELECT 1 FROM catalog.stores WITH (UPDLOCK,HOLDLOCK) WHERE id = @Id)
                THROW 52302, N'Dükkân kimliği zaten mevcut.', 1;
            INSERT catalog.stores (id, corporate_id, name, address_text, latitude, longitude, service_radius_km)
            VALUES (@Id,@CorporateId,TRIM(@Name),TRIM(@AddressText),@Latitude,@Longitude,@ServiceRadiusKm);
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM catalog.stores WITH (UPDLOCK,HOLDLOCK)
                WHERE id = @Id AND corporate_id = @CorporateId AND delete_date IS NULL)
                THROW 52301, N'Dükkân bu şirket kapsamında bulunamadı.', 1;
            IF @Operation = 'UPDATE'
                UPDATE catalog.stores SET name = TRIM(@Name), address_text = TRIM(@AddressText),
                    latitude = @Latitude, longitude = @Longitude, service_radius_km = @ServiceRadiusKm,
                    update_date = SYSUTCDATETIME() WHERE id = @Id AND corporate_id = @CorporateId;
            ELSE
                UPDATE catalog.stores SET is_active = @IsActive, update_date = SYSUTCDATETIME()
                WHERE id = @Id AND corporate_id = @CorporateId AND is_active <> @IsActive;
        END;
        COMMIT;
        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

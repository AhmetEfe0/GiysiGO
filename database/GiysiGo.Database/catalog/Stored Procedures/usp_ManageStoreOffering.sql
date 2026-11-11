CREATE PROCEDURE [catalog].[usp_ManageStoreOffering]
    @CorporateId uniqueidentifier, @StoreId uniqueidentifier, @CombinationId uniqueidentifier,
    @Operation nvarchar(20), @IsActive bit = NULL, @PriceOverride decimal(38,18) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Operation IS NULL OR @Operation NOT IN ('SAVE','SET_ACTIVE','SET_PRICE')
        OR (@Operation IN ('SAVE','SET_ACTIVE') AND @IsActive IS NULL)
        OR (@PriceOverride IS NOT NULL AND (@PriceOverride < 0 OR @PriceOverride > 9999999999.99 OR ROUND(@PriceOverride,2) <> @PriceOverride))
        THROW 52400, N'Geçersiz tarife komutu veya fiyat.', 1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM catalog.stores WITH (UPDLOCK,HOLDLOCK)
            WHERE id = @StoreId AND corporate_id = @CorporateId AND is_active = 1 AND delete_date IS NULL)
            THROW 52401, N'Aktif dükkân bu şirket kapsamında bulunamadı.', 1;

        DECLARE @Id uniqueidentifier, @Deleted datetime2(7);
        SELECT @Id = id, @Deleted = delete_date FROM catalog.store_offerings WITH (UPDLOCK,HOLDLOCK)
        WHERE store_id = @StoreId AND product_type_service_id = @CombinationId;
        IF @Operation <> 'SAVE' AND (@Id IS NULL OR @Deleted IS NOT NULL)
            THROW 52401, N'Dükkân hizmeti bulunamadı.', 1;

        -- Pasifleştirme, platform kombinasyonu sonradan kapanmış olsa da mümkündür.
        IF NOT (@Operation = 'SET_ACTIVE' AND @IsActive = 0)
            AND NOT EXISTS (
                SELECT 1 FROM catalog.product_type_services ps WITH (HOLDLOCK)
                JOIN catalog.product_types p WITH (HOLDLOCK) ON p.id = ps.product_type_id
                JOIN catalog.product_categories c WITH (HOLDLOCK) ON c.id = p.category_id
                JOIN catalog.services s WITH (HOLDLOCK) ON s.id = ps.service_id
                WHERE ps.id = @CombinationId AND ps.is_active = 1 AND ps.delete_date IS NULL
                    AND p.is_active = 1 AND p.delete_date IS NULL AND c.is_active = 1 AND c.delete_date IS NULL
                    AND s.is_active = 1 AND s.delete_date IS NULL)
            THROW 52401, N'Aktif ürün-hizmet kombinasyonu bulunamadı.', 1;
        IF @Id IS NULL
        BEGIN
            SET @Id = NEWID();
            INSERT catalog.store_offerings (id,store_id,product_type_service_id,price_override,is_active)
            VALUES (@Id,@StoreId,@CombinationId,@PriceOverride,@IsActive);
        END
        ELSE
            UPDATE catalog.store_offerings SET
                is_active = CASE WHEN @Operation IN ('SAVE','SET_ACTIVE') THEN @IsActive ELSE is_active END,
                price_override = CASE WHEN @Operation IN ('SAVE','SET_PRICE') THEN @PriceOverride ELSE price_override END,
                delete_date = NULL, update_date = SYSUTCDATETIME()
            WHERE id = @Id;
        COMMIT;
        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

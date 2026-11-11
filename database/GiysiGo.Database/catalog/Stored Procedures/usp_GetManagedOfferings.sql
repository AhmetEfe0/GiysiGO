CREATE PROCEDURE [catalog].[usp_GetManagedOfferings]
    @CorporateId uniqueidentifier, @StoreId uniqueidentifier, @Page int = 1, @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;
    IF @Page IS NULL OR @Page < 1 OR @PageSize IS NULL OR @PageSize NOT BETWEEN 1 AND 100
        THROW 52400, N'Geçersiz sayfalama.', 1;
    IF NOT EXISTS (SELECT 1 FROM catalog.stores WHERE id = @StoreId AND corporate_id = @CorporateId AND delete_date IS NULL)
        THROW 52401, N'Dükkân bu şirket kapsamında bulunamadı.', 1;
    SELECT o.id AS Id, o.product_type_service_id AS ProductTypeServiceId, o.price_override AS PriceOverride,
        ps.default_price AS DefaultPrice, COALESCE(o.price_override,ps.default_price) AS UnitPrice,
        ps.currency AS Currency, ps.price_unit AS PriceUnit, o.is_active AS IsActive
    INTO #ManagedOfferings
    FROM catalog.store_offerings o
    JOIN catalog.product_type_services ps ON ps.id = o.product_type_service_id
    WHERE o.store_id = @StoreId AND o.delete_date IS NULL;
    SELECT * FROM #ManagedOfferings ORDER BY ProductTypeServiceId, Id
    OFFSET ((CONVERT(bigint,@Page) - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
    SELECT COUNT_BIG(*) AS TotalCount FROM #ManagedOfferings;
END;
GO

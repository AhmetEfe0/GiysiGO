CREATE PROCEDURE [catalog].[usp_GetManagedStores]
    @CorporateId uniqueidentifier, @IncludeInactive bit = 0, @Page int = 1, @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;
    IF @CorporateId IS NULL OR @CorporateId = '00000000-0000-0000-0000-000000000000'
        OR @Page IS NULL OR @Page < 1 OR @PageSize IS NULL OR @PageSize NOT BETWEEN 1 AND 100
        THROW 52300, N'Şirket veya sayfalama bilgisi geçersiz.', 1;
    SELECT s.id AS Id,s.corporate_id AS CorporateId,s.name AS Name,s.address_text AS AddressText,
        s.latitude AS Latitude,s.longitude AS Longitude,s.service_radius_km AS ServiceRadiusKm,s.is_active AS IsActive,
        s.create_date AS CreateDate,s.update_date AS UpdateDate,s.delete_date AS DeleteDate
    INTO #VisibleStores
    FROM catalog.v_VisibleStores s
    WHERE s.corporate_id = @CorporateId AND (@IncludeInactive = 1 OR s.is_active = 1);
    SELECT * FROM #VisibleStores ORDER BY Name,Id
    OFFSET ((CONVERT(bigint,@Page)-1)*@PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
    SELECT COUNT_BIG(*) AS TotalCount FROM #VisibleStores;
END;
GO

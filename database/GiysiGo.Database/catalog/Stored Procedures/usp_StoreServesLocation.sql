CREATE PROCEDURE [catalog].[usp_StoreServesLocation]
    @StoreId uniqueidentifier, @Latitude decimal(18,9), @Longitude decimal(18,9)
AS
BEGIN
    SET NOCOUNT ON;
    IF @Latitude IS NULL OR @Latitude NOT BETWEEN -90 AND 90 OR @Longitude IS NULL OR @Longitude NOT BETWEEN -180 AND 180
        THROW 52300, N'Koordinat geçersiz.', 1;
    SELECT CAST(CASE WHEN EXISTS (
        SELECT 1 FROM catalog.v_VisibleStores s WITH (HOLDLOCK)
        CROSS APPLY (SELECT POWER(SIN(RADIANS((CONVERT(float,@Latitude)-s.latitude)/2)),2)
            + COS(RADIANS(CONVERT(float,s.latitude)))*COS(RADIANS(CONVERT(float,@Latitude)))
              * POWER(SIN(RADIANS((CONVERT(float,@Longitude)-s.longitude)/2)),2) AS Haversine) h
        WHERE s.id = @StoreId AND s.is_active = 1
          AND 2*6371.0*ASIN(SQRT(CASE WHEN h.Haversine > 1 THEN 1 WHEN h.Haversine < 0 THEN 0 ELSE h.Haversine END)) <= s.service_radius_km
    ) THEN 1 ELSE 0 END AS bit);
END;
GO

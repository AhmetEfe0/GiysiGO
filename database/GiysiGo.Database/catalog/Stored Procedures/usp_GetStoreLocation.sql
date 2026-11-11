CREATE PROCEDURE [catalog].[usp_GetStoreLocation] @StoreId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.id AS StoreId,s.address_text AS AddressText,s.latitude AS Latitude,s.longitude AS Longitude,s.is_active AS IsActive
    FROM catalog.v_VisibleStores s
    WHERE s.id = @StoreId AND s.is_active = 1;
END;
GO

CREATE PROCEDURE [catalog].[usp_GetManagedStore] @CorporateId uniqueidentifier, @Id uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.id AS Id,s.corporate_id AS CorporateId,s.name AS Name,s.address_text AS AddressText,
        s.latitude AS Latitude,s.longitude AS Longitude,s.service_radius_km AS ServiceRadiusKm,s.is_active AS IsActive,
        s.create_date AS CreateDate,s.update_date AS UpdateDate,s.delete_date AS DeleteDate
    FROM catalog.v_VisibleStores s
    WHERE s.id = @Id AND s.corporate_id = @CorporateId;
END;
GO

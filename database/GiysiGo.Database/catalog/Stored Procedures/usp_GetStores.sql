CREATE PROCEDURE [catalog].[usp_GetStores]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id AS Id, corporate_id AS CorporateId, name AS Name,
           address_text AS AddressText, latitude AS Latitude,
           longitude AS Longitude, service_radius_km AS ServiceRadiusKm,
           is_active AS IsActive, create_date AS CreateDate,
           update_date AS UpdateDate, delete_date AS DeleteDate
    FROM [catalog].[stores]
    WHERE delete_date IS NULL
      AND (@IncludeInactive = 1 OR is_active = 1)
    ORDER BY name, id;
END
GO

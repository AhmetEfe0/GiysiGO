CREATE PROCEDURE [catalog].[usp_GetStoreById]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id AS Id, corporate_id AS CorporateId, name AS Name,
           address_text AS AddressText, latitude AS Latitude,
           longitude AS Longitude, service_radius_km AS ServiceRadiusKm,
           is_active AS IsActive, create_date AS CreateDate,
           update_date AS UpdateDate, delete_date AS DeleteDate
    FROM [catalog].[stores]
    WHERE id = @Id AND delete_date IS NULL;
END
GO

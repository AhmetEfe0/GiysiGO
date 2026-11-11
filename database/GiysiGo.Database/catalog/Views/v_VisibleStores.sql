CREATE VIEW [catalog].[v_VisibleStores]
AS
    -- Panel pasif dükkânı görebilir; müşteri okuyucuları ayrıca is_active = 1 arar.
    SELECT s.id,s.corporate_id,s.name,s.address_text,s.latitude,s.longitude,s.service_radius_km,
        s.is_active,s.create_date,s.update_date,s.delete_date
    FROM catalog.stores s
    WHERE s.delete_date IS NULL;
GO

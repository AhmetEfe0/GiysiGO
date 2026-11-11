CREATE PROCEDURE [catalog].[usp_GetValidStoreOffering]
    @StoreId uniqueidentifier, @ProductTypeId uniqueidentifier, @ServiceId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.id AS StoreId,p.id AS ProductTypeId,v.id AS ServiceId,o.id AS StoreOfferingId,
        COALESCE(o.price_override,ps.default_price) AS UnitPrice,ps.price_unit AS PriceUnit,CAST(1 AS bit) AS IsActive,
        ps.selection_kind AS SelectionKind,ps.is_default_selected AS IsDefaultSelected
    FROM catalog.v_VisibleStores s WITH (HOLDLOCK)
    JOIN catalog.store_offerings o WITH (HOLDLOCK) ON o.store_id = s.id AND o.is_active = 1 AND o.delete_date IS NULL
    JOIN catalog.product_type_services ps WITH (HOLDLOCK) ON ps.id = o.product_type_service_id AND ps.is_active = 1 AND ps.delete_date IS NULL
    JOIN catalog.product_types p WITH (HOLDLOCK) ON p.id = ps.product_type_id AND p.is_active = 1 AND p.delete_date IS NULL
    JOIN catalog.product_categories pc WITH (HOLDLOCK) ON pc.id = p.category_id AND pc.is_active = 1 AND pc.delete_date IS NULL
    JOIN catalog.services v WITH (HOLDLOCK) ON v.id = ps.service_id AND v.is_active = 1 AND v.delete_date IS NULL
    WHERE s.id = @StoreId AND p.id = @ProductTypeId AND v.id = @ServiceId AND s.is_active = 1;
END;
GO

CREATE PROCEDURE [catalog].[usp_GetProductTypeServices]
    @ProductTypeId UNIQUEIDENTIFIER = NULL,
    @ServiceId UNIQUEIDENTIFIER = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id AS Id, create_date AS CreateDate, update_date AS UpdateDate,
           delete_date AS DeleteDate, product_type_id AS ProductTypeId,
           service_id AS ServiceId, default_price AS DefaultPrice,
           currency AS Currency, price_unit AS PriceUnit,
           selection_kind AS SelectionKind,
           is_default_selected AS IsDefaultSelected, is_active AS IsActive
    FROM [catalog].[product_type_services]
    WHERE delete_date IS NULL
      AND (@ProductTypeId IS NULL OR product_type_id = @ProductTypeId)
      AND (@ServiceId IS NULL OR service_id = @ServiceId)
      AND (@IncludeInactive = 1 OR is_active = 1)
    ORDER BY product_type_id, service_id, id;
END
GO

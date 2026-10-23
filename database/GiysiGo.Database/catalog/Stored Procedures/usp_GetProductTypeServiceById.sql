CREATE PROCEDURE [catalog].[usp_GetProductTypeServiceById]
    @Id UNIQUEIDENTIFIER
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
    WHERE id = @Id AND delete_date IS NULL;
END
GO

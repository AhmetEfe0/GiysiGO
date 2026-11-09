CREATE PROCEDURE [catalog].[usp_GetStoreScope]
    @StoreId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id AS StoreId, corporate_id AS CorporateId, is_active AS IsActive
    FROM catalog.stores
    WHERE id = @StoreId AND delete_date IS NULL;
END;
GO

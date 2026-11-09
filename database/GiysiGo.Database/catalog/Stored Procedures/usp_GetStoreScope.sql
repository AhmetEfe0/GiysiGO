CREATE PROCEDURE [catalog].[usp_GetStoreScope] @StoreId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.id AS StoreId,s.corporate_id AS CorporateId,s.is_active AS IsActive
    FROM catalog.v_VisibleStores s
    WHERE s.id = @StoreId;
END;
GO

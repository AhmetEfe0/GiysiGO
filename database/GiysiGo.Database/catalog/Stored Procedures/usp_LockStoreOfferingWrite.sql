CREATE PROCEDURE [catalog].[usp_LockStoreOfferingWrite]
    @CorporateId uniqueidentifier, @StoreId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    -- Serialize writers before the permission reader acquires shared scope locks.
    DECLARE @Id uniqueidentifier;
    SELECT @Id = id FROM catalog.stores WITH (UPDLOCK,HOLDLOCK)
    WHERE id = @StoreId AND corporate_id = @CorporateId;
END;
GO

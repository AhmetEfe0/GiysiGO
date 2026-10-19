CREATE PROCEDURE [identity].[spHasPermission]
    @UserId uniqueidentifier,
    @PermissionCode nvarchar(max),
    @CorporateId uniqueidentifier = NULL,
    @StoreId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @UserId IS NULL OR @UserId = '00000000-0000-0000-0000-000000000000'
        OR @PermissionCode IS NULL OR DATALENGTH(@PermissionCode) > 200
        OR NOT EXISTS (SELECT 1 FROM [identity].users WHERE id = @UserId AND is_active = 1 AND delete_date IS NULL)
        OR (@CorporateId IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM [identity].corporates WHERE id = @CorporateId AND is_active = 1 AND delete_date IS NULL))
    BEGIN
        SELECT CAST(0 AS bit) AS IsAllowed;
        RETURN;
    END;

    DECLARE @Allowed bit = 0;

    IF EXISTS (
        SELECT 1 FROM [identity].permissions p
        JOIN [identity].role_permissions rp ON rp.permission_id = p.id AND rp.delete_date IS NULL
        JOIN [identity].roles r ON r.id = rp.role_id AND r.is_active = 1 AND r.delete_date IS NULL AND r.scope = 'GLOBAL'
        JOIN [identity].user_roles ur ON ur.role_id = r.id AND ur.user_id = @UserId AND ur.delete_date IS NULL
        WHERE p.code = @PermissionCode AND p.is_active = 1 AND p.delete_date IS NULL
    ) SET @Allowed = 1;

    IF @Allowed = 0 AND @CorporateId IS NOT NULL AND EXISTS (
        SELECT 1 FROM [identity].permissions p
        JOIN [identity].role_permissions rp ON rp.permission_id = p.id AND rp.delete_date IS NULL
        JOIN [identity].roles r ON r.id = rp.role_id AND r.is_active = 1 AND r.delete_date IS NULL AND r.scope = 'CORPORATE'
        JOIN [identity].corporate_memberships cm ON cm.role_id = r.id AND cm.user_id = @UserId
            AND cm.corporate_id = @CorporateId AND cm.is_active = 1 AND cm.delete_date IS NULL
        WHERE p.code = @PermissionCode AND p.is_active = 1 AND p.delete_date IS NULL
    ) SET @Allowed = 1;

    IF @Allowed = 0 AND @StoreId IS NOT NULL AND EXISTS (
        SELECT 1 FROM [identity].permissions p
        JOIN [identity].role_permissions rp ON rp.permission_id = p.id AND rp.delete_date IS NULL
        JOIN [identity].roles r ON r.id = rp.role_id AND r.is_active = 1 AND r.delete_date IS NULL AND r.scope = 'STORE'
        JOIN [identity].store_assignments sa ON sa.role_id = r.id AND sa.user_id = @UserId
            AND sa.store_id = @StoreId AND sa.is_active = 1 AND sa.delete_date IS NULL
        WHERE p.code = @PermissionCode AND p.is_active = 1 AND p.delete_date IS NULL
    ) SET @Allowed = 1;

    SELECT @Allowed AS IsAllowed;
END;
GO

CREATE PROCEDURE [identity].[spHasPermission]
    @UserId uniqueidentifier,
    @PermissionCode nvarchar(100),
    @CorporateId uniqueidentifier = NULL,
    @StoreId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PermissionId uniqueidentifier;
    SELECT @PermissionId = id FROM [identity].permissions
    WHERE code = @PermissionCode AND is_active = 1 AND delete_date IS NULL;
    IF @PermissionId IS NULL
       OR NOT EXISTS (SELECT 1 FROM [identity].users WHERE id = @UserId AND is_active = 1 AND delete_date IS NULL)
       OR (@CorporateId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [identity].corporates WHERE id = @CorporateId AND is_active = 1 AND delete_date IS NULL))
       OR (@StoreId IS NOT NULL AND @CorporateId IS NULL)
    BEGIN
        SELECT CAST(0 AS bit);
        RETURN;
    END;

    -- Kapsamsız çağrıda yalnız GLOBAL rol geçerlidir; JWT rol iddiaları kullanılmaz.
    SELECT CAST(CASE WHEN
        EXISTS (
            SELECT 1 FROM [identity].user_roles ur
            JOIN [identity].roles r ON r.id = ur.role_id AND r.scope = N'GLOBAL'
            JOIN [identity].role_permissions rp ON rp.role_id = r.id
            WHERE ur.user_id = @UserId AND ur.delete_date IS NULL
              AND r.is_active = 1 AND r.delete_date IS NULL
              AND rp.permission_id = @PermissionId AND rp.delete_date IS NULL
        )
        OR (@CorporateId IS NOT NULL AND EXISTS (
            SELECT 1 FROM [identity].corporate_memberships cm
            JOIN [identity].roles r ON r.id = cm.role_id AND r.scope = N'CORPORATE'
            JOIN [identity].role_permissions rp ON rp.role_id = r.id
            WHERE cm.user_id = @UserId AND cm.corporate_id = @CorporateId
              AND cm.is_active = 1 AND cm.delete_date IS NULL
              AND r.is_active = 1 AND r.delete_date IS NULL
              AND rp.permission_id = @PermissionId AND rp.delete_date IS NULL
        ))
        OR (@StoreId IS NOT NULL AND EXISTS (
            SELECT 1 FROM [identity].store_assignments sa
            JOIN [identity].roles r ON r.id = sa.role_id AND r.scope = N'STORE'
            JOIN [identity].role_permissions rp ON rp.role_id = r.id
            WHERE sa.user_id = @UserId AND sa.store_id = @StoreId
              AND sa.is_active = 1 AND sa.delete_date IS NULL
              AND r.is_active = 1 AND r.delete_date IS NULL
              AND rp.permission_id = @PermissionId AND rp.delete_date IS NULL
        ))
        THEN 1 ELSE 0 END AS bit);
END;
GO

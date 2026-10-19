CREATE PROCEDURE [identity].[spCanManageStaffAssignment]
    @ActorUserId uniqueidentifier,
    @TargetUserId uniqueidentifier,
    @TargetRoleId uniqueidentifier,
    @CorporateId uniqueidentifier,
    @StoreId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ActorUserId IS NULL OR @TargetUserId IS NULL OR @ActorUserId = @TargetUserId
        OR @CorporateId IS NULL OR NOT EXISTS (
            SELECT 1 FROM [identity].users WHERE id = @ActorUserId AND is_active = 1 AND delete_date IS NULL)
        OR NOT EXISTS (
            SELECT 1 FROM [identity].users WHERE id = @TargetUserId AND is_active = 1 AND delete_date IS NULL)
        OR NOT EXISTS (
            SELECT 1 FROM [identity].corporates WHERE id = @CorporateId AND is_active = 1 AND delete_date IS NULL)
    BEGIN
        SELECT CAST(0 AS bit) AS IsAllowed;
        RETURN;
    END;

    DECLARE @TargetCode nvarchar(100);
    SELECT @TargetCode = code FROM [identity].roles
    WHERE id = @TargetRoleId AND is_active = 1 AND delete_date IS NULL
        AND ((@StoreId IS NULL AND scope = 'CORPORATE' AND code = 'CorporateOwner')
             OR (@StoreId IS NOT NULL AND scope = 'STORE' AND code IN ('StoreManager', 'StoreStaff')));
    IF @TargetCode IS NULL
    BEGIN
        SELECT CAST(0 AS bit) AS IsAllowed;
        RETURN;
    END;

    DECLARE @Allowed bit = 0;
    IF EXISTS (
        SELECT 1 FROM [identity].user_roles ur
        JOIN [identity].roles role ON role.id = ur.role_id AND role.code = 'PlatformAdmin'
            AND role.scope = 'GLOBAL' AND role.is_active = 1 AND role.delete_date IS NULL
        JOIN [identity].role_permissions grantRow ON grantRow.role_id = role.id AND grantRow.delete_date IS NULL
        JOIN [identity].permissions permission ON permission.id = grantRow.permission_id
            AND permission.code = 'store.staff.manage' AND permission.is_active = 1 AND permission.delete_date IS NULL
        WHERE ur.user_id = @ActorUserId AND ur.delete_date IS NULL
    ) SET @Allowed = 1;

    IF @Allowed = 0 AND @StoreId IS NOT NULL AND EXISTS (
        SELECT 1 FROM [identity].corporate_memberships membership
        JOIN [identity].roles role ON role.id = membership.role_id AND role.code = 'CorporateOwner'
            AND role.scope = 'CORPORATE' AND role.is_active = 1 AND role.delete_date IS NULL
        JOIN [identity].role_permissions grantRow ON grantRow.role_id = role.id AND grantRow.delete_date IS NULL
        JOIN [identity].permissions permission ON permission.id = grantRow.permission_id
            AND permission.code = 'store.staff.manage' AND permission.is_active = 1 AND permission.delete_date IS NULL
        WHERE membership.user_id = @ActorUserId AND membership.corporate_id = @CorporateId
            AND membership.is_active = 1 AND membership.delete_date IS NULL
    ) SET @Allowed = 1;

    IF @Allowed = 0 AND @StoreId IS NOT NULL AND @TargetCode = 'StoreStaff' AND EXISTS (
        SELECT 1 FROM [identity].store_assignments assignment
        JOIN [identity].roles role ON role.id = assignment.role_id AND role.code = 'StoreManager'
            AND role.scope = 'STORE' AND role.is_active = 1 AND role.delete_date IS NULL
        JOIN [identity].role_permissions grantRow ON grantRow.role_id = role.id AND grantRow.delete_date IS NULL
        JOIN [identity].permissions permission ON permission.id = grantRow.permission_id
            AND permission.code = 'store.staff.manage' AND permission.is_active = 1 AND permission.delete_date IS NULL
        WHERE assignment.user_id = @ActorUserId AND assignment.store_id = @StoreId
            AND assignment.is_active = 1 AND assignment.delete_date IS NULL
    ) SET @Allowed = 1;

    SELECT @Allowed AS IsAllowed;
END;
GO

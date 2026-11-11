CREATE PROCEDURE [identity].[spGrantCustomerRole]
    @UserId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RoleId uniqueidentifier;
    SELECT @RoleId = id FROM [identity].roles WITH (UPDLOCK, HOLDLOCK)
    WHERE code = 'Customer' AND scope = 'GLOBAL' AND is_active = 1 AND delete_date IS NULL;
    IF @RoleId IS NULL THROW 51002, 'Active Customer role was not found.', 1;
    IF NOT EXISTS (SELECT 1 FROM [identity].users WHERE id = @UserId AND is_active = 1 AND delete_date IS NULL)
        THROW 51002, 'Active user was not found.', 1;

    IF NOT EXISTS (SELECT 1 FROM [identity].user_roles WITH (UPDLOCK, HOLDLOCK)
                   WHERE user_id = @UserId AND role_id = @RoleId AND delete_date IS NULL)
        INSERT [identity].user_roles(id, user_id, role_id, role_scope)
        VALUES (NEWID(), @UserId, @RoleId, 'GLOBAL');
END;
GO

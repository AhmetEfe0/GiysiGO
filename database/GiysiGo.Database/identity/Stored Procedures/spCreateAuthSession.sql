CREATE PROCEDURE [identity].[spCreateAuthSession]
    @Id uniqueidentifier,
    @UserId uniqueidentifier,
    @TokenHash binary(32),
    @ExpiresAtUtc datetime2(7)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Id IS NULL OR @Id = '00000000-0000-0000-0000-000000000000'
       OR @TokenHash IS NULL OR @ExpiresAtUtc <= SYSUTCDATETIME()
       OR NOT EXISTS (SELECT 1 FROM [identity].users WHERE id = @UserId AND is_active = 1 AND delete_date IS NULL)
        THROW 51002, 'Active user or valid session was not found.', 1;
    INSERT [identity].auth_sessions(id, user_id, token_hash, expires_at_utc)
    VALUES (@Id, @UserId, @TokenHash, @ExpiresAtUtc);
END;
GO

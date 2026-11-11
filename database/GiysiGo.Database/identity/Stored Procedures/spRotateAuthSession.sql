CREATE PROCEDURE [identity].[spRotateAuthSession]
    @OldTokenHash binary(32),
    @NewId uniqueidentifier,
    @NewTokenHash binary(32),
    @NewExpiresAtUtc datetime2(7)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @OldId uniqueidentifier, @UserId uniqueidentifier;
    SELECT @OldId = session.id, @UserId = session.user_id
    FROM [identity].auth_sessions session WITH (UPDLOCK, HOLDLOCK)
    JOIN [identity].users user_row ON user_row.id = session.user_id
    WHERE session.token_hash = @OldTokenHash AND session.revoked_at_utc IS NULL
      AND session.delete_date IS NULL AND session.expires_at_utc > SYSUTCDATETIME()
      AND user_row.is_active = 1 AND user_row.delete_date IS NULL;

    IF @OldId IS NULL OR @NewId IS NULL OR @NewId = '00000000-0000-0000-0000-000000000000'
       OR @NewTokenHash IS NULL OR @NewExpiresAtUtc <= SYSUTCDATETIME()
    BEGIN
        SELECT CAST(NULL AS uniqueidentifier) AS UserId;
        RETURN;
    END;

    UPDATE [identity].auth_sessions
    SET revoked_at_utc = SYSUTCDATETIME(), replaced_by_id = @NewId, update_date = SYSUTCDATETIME()
    WHERE id = @OldId;
    INSERT [identity].auth_sessions(id, user_id, token_hash, expires_at_utc)
    VALUES (@NewId, @UserId, @NewTokenHash, @NewExpiresAtUtc);
    SELECT @UserId AS UserId;
END;
GO

CREATE PROCEDURE [identity].[spRevokeAuthSession]
    @TokenHash binary(32)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    UPDATE [identity].auth_sessions
    SET revoked_at_utc = SYSUTCDATETIME(), update_date = SYSUTCDATETIME()
    WHERE token_hash = @TokenHash AND revoked_at_utc IS NULL AND delete_date IS NULL;
END;
GO

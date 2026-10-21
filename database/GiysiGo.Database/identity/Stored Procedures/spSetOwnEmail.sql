CREATE PROCEDURE [identity].[spSetOwnEmail]
    @UserId uniqueidentifier,
    @Email nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Email IS NULL OR DATALENGTH(@Email) > 640 OR LEN(LTRIM(RTRIM(@Email))) < 4
        THROW 51000, 'A valid email is required.', 1;
    UPDATE [identity].users
    SET email = LTRIM(RTRIM(@Email)), update_date = SYSUTCDATETIME()
    WHERE id = @UserId AND delete_date IS NULL AND is_active = 1;
    IF @@ROWCOUNT = 0 THROW 51001, 'Active user was not found.', 1;
END;
GO

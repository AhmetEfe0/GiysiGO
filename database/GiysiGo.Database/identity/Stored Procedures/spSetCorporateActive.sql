CREATE PROCEDURE [identity].[spSetCorporateActive]
    @Id uniqueidentifier, @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @IsActive IS NULL THROW 51002, 'Active state is required.', 1;
    IF NOT EXISTS (SELECT 1 FROM [identity].corporates WITH (UPDLOCK,HOLDLOCK) WHERE id=@Id AND delete_date IS NULL)
        THROW 51001, 'Corporate was not found.', 1;
    UPDATE [identity].corporates SET is_active=@IsActive,update_date=SYSUTCDATETIME()
    WHERE id=@Id AND is_active<>@IsActive;
END;
GO

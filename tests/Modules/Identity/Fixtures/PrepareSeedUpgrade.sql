SET NOCOUNT ON;
DECLARE @UserId uniqueidentifier = NEWID();
DECLARE @RoleId uniqueidentifier = (SELECT id FROM [identity].roles WHERE code = N'PlatformAdmin');
INSERT [identity].users (id, email, password_hash)
VALUES (@UserId, CONCAT(CONVERT(nvarchar(36), @UserId), N'@seed-upgrade.test'), N'test-only');
EXEC [identity].spGrantUserRole @UserId = @UserId, @RoleId = @RoleId;

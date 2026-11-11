DECLARE @PreviousId uniqueidentifier;
SELECT @PreviousId = id FROM [identity].permissions WHERE code = @Code;
IF @PreviousId IS NULL THROW 52900, N'Test izni bulunamadı.', 1;
UPDATE [identity].permissions SET code = CONCAT(N'test.legacy.',CONVERT(nvarchar(36),@PreviousId)) WHERE id = @PreviousId;
INSERT [identity].permissions (id,code,description,is_active,create_date,update_date,delete_date)
SELECT @LegacyId,@Code,@Description,@IsActive,create_date,update_date,@DeleteDate
FROM [identity].permissions WHERE id = @PreviousId;
UPDATE [identity].role_permissions SET permission_id = @LegacyId WHERE permission_id = @PreviousId;
DELETE FROM [identity].permissions WHERE id = @PreviousId;
IF @RevokeOwner = 1
    UPDATE rp SET delete_date = SYSUTCDATETIME(),update_date = SYSUTCDATETIME()
    FROM [identity].role_permissions rp JOIN [identity].roles r ON r.id = rp.role_id
    WHERE rp.permission_id = @LegacyId AND r.code = 'CorporateOwner';

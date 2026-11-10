SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

UPDATE [identity].permissions SET is_active = 0, update_date = SYSUTCDATETIME()
WHERE code = 'order.fulfill' AND is_active = 1 AND delete_date IS NULL;
IF @@ROWCOUNT <> 1
    THROW 51990, 'Expected one active order.fulfill permission.', 1;

UPDATE rp SET delete_date = SYSUTCDATETIME(), update_date = SYSUTCDATETIME()
FROM [identity].role_permissions rp
JOIN [identity].roles role ON role.id = rp.role_id AND role.code = 'StoreManager'
JOIN [identity].permissions permission ON permission.id = rp.permission_id AND permission.code = 'quote.approve'
WHERE rp.delete_date IS NULL;
IF @@ROWCOUNT <> 1
    THROW 51991, 'Expected one active StoreManager quote.approve grant.', 1;

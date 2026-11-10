SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM [identity].roles WHERE code IN (N'Customer', N'PlatformAdmin', N'CorporateOwner', N'StoreManager', N'StoreStaff')) <> 5
    THROW 52301, N'Beş sabit rol bulunmalıdır.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles r JOIN [identity].role_permissions rp ON rp.role_id = r.id JOIN [identity].permissions p ON p.id = rp.permission_id WHERE r.code = N'StoreStaff' AND p.code = N'quote.prepare' AND rp.delete_date IS NULL)
    THROW 52301, N'Personelin teklif hazırlama izni eksik.', 1;
IF EXISTS (SELECT 1 FROM [identity].roles r JOIN [identity].role_permissions rp ON rp.role_id = r.id JOIN [identity].permissions p ON p.id = rp.permission_id WHERE r.code = N'StoreStaff' AND p.code = N'quote.approve' AND rp.delete_date IS NULL)
    THROW 52301, N'Personelin teklif yayımlama izni olmamalıdır.', 1;
IF (SELECT COUNT(*) FROM [identity].roles r JOIN [identity].role_permissions rp ON rp.role_id = r.id JOIN [identity].permissions p ON p.id = rp.permission_id WHERE p.code = N'catalog.manage' AND rp.delete_date IS NULL AND r.code = N'PlatformAdmin') <> 1
    THROW 52301, N'Platform yöneticisinin katalog yönetimi izni eksik.', 1;
SELECT snapshot FROM (
    SELECT CONCAT(N'R|', code, N'|', id, N'|', scope, N'|', is_active) snapshot
    FROM [identity].roles WHERE code IN (N'Customer', N'PlatformAdmin', N'CorporateOwner', N'StoreManager', N'StoreStaff')
    UNION ALL
    SELECT CONCAT(N'P|', code, N'|', id, N'|', is_active) FROM [identity].permissions
    WHERE code IN (N'catalog.manage', N'store.view', N'store.staff.manage', N'store.offering.manage', N'order.view', N'order.inspect', N'quote.prepare', N'quote.approve', N'order.process', N'order.fulfill')
    UNION ALL
    SELECT CONCAT(N'RP|', r.code, N'|', p.code, N'|', rp.id, N'|', rp.role_id, N'|', rp.permission_id)
    FROM [identity].role_permissions rp JOIN [identity].roles r ON r.id = rp.role_id JOIN [identity].permissions p ON p.id = rp.permission_id
    WHERE r.code IN (N'Customer', N'PlatformAdmin', N'CorporateOwner', N'StoreManager', N'StoreStaff') AND rp.delete_date IS NULL
) snapshots ORDER BY snapshot;

UPDATE rp SET delete_date = SYSUTCDATETIME()
FROM [identity].role_permissions rp
JOIN [identity].roles r ON r.id = rp.role_id
JOIN [identity].permissions p ON p.id = rp.permission_id
WHERE r.code = N'StoreStaff' AND p.code = N'quote.prepare';
UPDATE [identity].roles SET is_active = 0 WHERE code = N'StoreManager';
UPDATE [identity].permissions SET is_active = 0 WHERE code = N'order.process';

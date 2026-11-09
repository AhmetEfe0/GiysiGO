UPDATE [identity].permissions SET is_active = 0 WHERE code = 'store.manage';
UPDATE rp SET delete_date = SYSUTCDATETIME() FROM [identity].role_permissions rp
JOIN [identity].permissions p ON p.id = rp.permission_id AND p.code = 'store.manage'
JOIN [identity].roles r ON r.id = rp.role_id AND r.code = 'CorporateOwner';

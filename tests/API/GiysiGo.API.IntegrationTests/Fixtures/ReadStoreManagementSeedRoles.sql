SELECT r.code FROM [identity].role_permissions rp
JOIN [identity].roles r ON r.id = rp.role_id
JOIN [identity].permissions p ON p.id = rp.permission_id
WHERE p.code = 'store.manage' AND rp.delete_date IS NULL ORDER BY r.code;

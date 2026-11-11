SELECT CONCAT(CONVERT(nvarchar(36),p.id),'|',p.is_active,'|',CONVERT(nvarchar(36),rp.id),'|',CONVERT(nvarchar(36),rp.role_id),'|',COALESCE(CONVERT(nvarchar(33),rp.delete_date,126),'CANLI')) AS State
FROM [identity].permissions p
JOIN [identity].role_permissions rp ON rp.permission_id = p.id
WHERE p.code = 'store.manage' ORDER BY rp.id;

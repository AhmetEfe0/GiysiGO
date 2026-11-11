SELECT State FROM (
    SELECT CONCAT(N'P|',code,N'|',description,N'|',is_active,N'|',CONVERT(nvarchar(33),create_date,126),N'|',
        COALESCE(CONVERT(nvarchar(33),update_date,126),N'NULL'),N'|',COALESCE(CONVERT(nvarchar(33),delete_date,126),N'NULL')) AS State
    FROM [identity].permissions WHERE code = 'store.manage'
    UNION ALL
    SELECT CONCAT(N'G|',rp.id,N'|',rp.role_id,N'|',CONVERT(nvarchar(33),rp.create_date,126),N'|',
        COALESCE(CONVERT(nvarchar(33),rp.update_date,126),N'NULL'),N'|',COALESCE(CONVERT(nvarchar(33),rp.delete_date,126),N'NULL'))
    FROM [identity].role_permissions rp JOIN [identity].permissions p ON p.id = rp.permission_id
    WHERE p.code = 'store.manage'
) snapshots ORDER BY State;

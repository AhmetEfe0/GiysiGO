SET NOCOUNT ON;
SELECT snapshot FROM (
    SELECT CONCAT(N'R|', code, N'|', id, N'|', scope, N'|', is_active, N'|', delete_date) AS snapshot
    FROM [identity].roles
    UNION ALL
    SELECT CONCAT(N'P|', code, N'|', id, N'|', is_active, N'|', delete_date)
    FROM [identity].permissions
    UNION ALL
    SELECT CONCAT(N'RP|', id, N'|', role_id, N'|', permission_id, N'|', delete_date)
    FROM [identity].role_permissions
    UNION ALL
    SELECT CONCAT(N'UR|', id, N'|', user_id, N'|', role_id, N'|', delete_date)
    FROM [identity].user_roles
) AS state ORDER BY snapshot;

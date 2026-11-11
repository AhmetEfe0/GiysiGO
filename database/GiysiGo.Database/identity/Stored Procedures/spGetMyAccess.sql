CREATE PROCEDURE [identity].[spGetMyAccess] @UserId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    WITH Assignments AS (
        SELECT CAST(NULL AS uniqueidentifier) AS CorporateId,CAST(NULL AS uniqueidentifier) AS StoreId,
            CAST(NULL AS nvarchar(200)) AS CorporateName,ur.role_id
        FROM [identity].user_roles ur WHERE ur.user_id=@UserId AND ur.delete_date IS NULL
        UNION ALL
        SELECT c.id,NULL,c.name,m.role_id FROM [identity].corporate_memberships m
        JOIN [identity].corporates c ON c.id=m.corporate_id AND c.is_active=1 AND c.delete_date IS NULL
        WHERE m.user_id=@UserId AND m.is_active=1 AND m.delete_date IS NULL
        UNION ALL
        SELECT NULL,a.store_id,NULL,a.role_id FROM [identity].store_assignments a
        WHERE a.user_id=@UserId AND a.is_active=1 AND a.delete_date IS NULL
        UNION ALL
        SELECT c.id,NULL,c.name,ur.role_id FROM [identity].user_roles ur
        JOIN [identity].roles r ON r.id=ur.role_id AND r.code='PlatformAdmin' AND r.scope='GLOBAL'
        CROSS JOIN [identity].corporates c
        WHERE ur.user_id=@UserId AND ur.delete_date IS NULL AND c.is_active=1 AND c.delete_date IS NULL
            AND EXISTS (SELECT 1 FROM [identity].role_permissions rp
                JOIN [identity].permissions p ON p.id=rp.permission_id AND p.code='store.staff.manage' AND p.is_active=1 AND p.delete_date IS NULL
                WHERE rp.role_id=r.id AND rp.delete_date IS NULL)
    )
    SELECT a.CorporateId,a.StoreId,a.CorporateName,r.id AS RoleId,r.code AS RoleCode,p.code AS PermissionCode
    FROM Assignments a
    JOIN [identity].roles r ON r.id=a.role_id AND r.is_active=1 AND r.delete_date IS NULL
    LEFT JOIN [identity].role_permissions rp ON rp.role_id=r.id AND rp.delete_date IS NULL
    LEFT JOIN [identity].permissions p ON p.id=rp.permission_id AND p.is_active=1 AND p.delete_date IS NULL
    WHERE EXISTS (SELECT 1 FROM [identity].users WHERE id=@UserId AND is_active=1 AND delete_date IS NULL)
    ORDER BY a.CorporateId,a.StoreId,r.code,p.code;
END;
GO

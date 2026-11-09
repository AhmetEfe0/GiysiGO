-- #14: yalnız şirket sahibi ve platform yöneticisi fiziksel dükkân yönetir.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM [identity].permissions WITH (UPDLOCK,HOLDLOCK) WHERE code = 'store.manage')
        INSERT [identity].permissions (id,code,description) VALUES (NEWID(),'store.manage',N'Şirkete bağlı fiziksel dükkânları yönetme');
    INSERT [identity].role_permissions (id,role_id,permission_id)
    SELECT NEWID(),r.id,p.id FROM [identity].roles r
    JOIN [identity].permissions p ON p.code = 'store.manage'
    WHERE ((r.code = 'PlatformAdmin' AND r.scope = 'GLOBAL') OR (r.code = 'CorporateOwner' AND r.scope = 'CORPORATE'))
      AND NOT EXISTS (SELECT 1 FROM [identity].role_permissions rp WITH (UPDLOCK,HOLDLOCK) WHERE rp.role_id = r.id AND rp.permission_id = p.id);
    COMMIT;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    THROW;
END CATCH;

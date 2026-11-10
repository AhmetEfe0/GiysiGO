SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
BEGIN TRANSACTION;
IF @Operation = N'CREATE'
BEGIN
    DECLARE @AdminRole uniqueidentifier = (SELECT id FROM [identity].roles WHERE code = N'PlatformAdmin');
    DECLARE @CustomerRole uniqueidentifier = (SELECT id FROM [identity].roles WHERE code = N'Customer');
    DECLARE @OwnerRole uniqueidentifier = (SELECT id FROM [identity].roles WHERE code = N'CorporateOwner');
    DECLARE @SeedStaffRole uniqueidentifier = (SELECT id FROM [identity].roles WHERE code = N'StoreStaff');
    IF @AdminRole IS NULL OR @CustomerRole IS NULL OR @OwnerRole IS NULL OR @SeedStaffRole IS NULL
        THROW 52300, N'Yetkilendirme testi için rol seed kayıtları gerekli.', 1;
    IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions rp JOIN [identity].permissions p ON p.id = rp.permission_id WHERE rp.role_id = @SeedStaffRole AND p.code = N'quote.prepare' AND rp.delete_date IS NULL)
       OR EXISTS (SELECT 1 FROM [identity].role_permissions rp JOIN [identity].permissions p ON p.id = rp.permission_id WHERE rp.role_id = @SeedStaffRole AND p.code IN (N'quote.approve', N'catalog.manage') AND rp.delete_date IS NULL)
        THROW 52300, N'Personelin hazırlama/yayımlama/katalog izinleri seed ile uyuşmuyor.', 1;
    IF EXISTS (SELECT 1 FROM [identity].role_permissions rp JOIN [identity].permissions p ON p.id = rp.permission_id WHERE p.code = N'catalog.manage' AND rp.role_id <> @AdminRole AND rp.delete_date IS NULL)
        THROW 52300, N'Katalog yönetimi seed içinde yalnız platform yöneticisine verilmelidir.', 1;

    INSERT [identity].users (id, email, password_hash) VALUES
        (@AdminId, CONCAT(@CodePrefix, N'-admin@test.invalid'), N'test'),
        (@CustomerId, CONCAT(@CodePrefix, N'-customer@test.invalid'), N'test'),
        (@StaffId, CONCAT(@CodePrefix, N'-staff@test.invalid'), N'test'),
        (@OwnerId, CONCAT(@CodePrefix, N'-owner@test.invalid'), N'test');
    INSERT [identity].user_roles (id, user_id, role_id) VALUES (NEWID(), @AdminId, @AdminRole), (NEWID(), @CustomerId, @CustomerRole);
    INSERT [identity].corporates (id, name) VALUES (@CorporateA, N'A şirketi'), (@CorporateB, N'B şirketi');
    INSERT catalog.stores (id, corporate_id, name, address_text, latitude, longitude, service_radius_km) VALUES
        (@StoreA, @CorporateA, N'A dükkânı', N'Test', 41, 29, 10),
        (@StoreB, @CorporateB, N'B dükkânı', N'Test', 41, 29, 10);
    INSERT [identity].roles (id, code, name, scope) VALUES (@StaffRoleId, CONCAT(@CodePrefix, N'-staff'), N'Ayrılmış test personeli', N'STORE');
    INSERT [identity].role_permissions (id, role_id, permission_id)
    SELECT NEWID(), @StaffRoleId, permission_id FROM [identity].role_permissions WHERE role_id = @SeedStaffRole AND delete_date IS NULL;
    INSERT [identity].store_assignments (id, user_id, store_id, role_id) VALUES (NEWID(), @StaffId, @StoreA, @StaffRoleId);
    INSERT [identity].corporate_memberships (id, user_id, corporate_id, role_id) VALUES (NEWID(), @OwnerId, @CorporateA, @OwnerRole);
END
ELSE IF @Operation = N'REVOKE_ADMIN'
    UPDATE [identity].user_roles SET delete_date = SYSUTCDATETIME() WHERE user_id = @AdminId;
ELSE IF @Operation = N'DISABLE_ADMIN'
    UPDATE [identity].users SET is_active = 0 WHERE id = @AdminId;
ELSE IF @Operation = N'DELETE_ADMIN'
    UPDATE [identity].users SET delete_date = SYSUTCDATETIME() WHERE id = @AdminId;
ELSE IF @Operation = N'DISABLE_STAFF_ROLE'
    UPDATE [identity].roles SET is_active = 0 WHERE id = @StaffRoleId;
ELSE IF @Operation = N'ENABLE_STAFF_ROLE'
    UPDATE [identity].roles SET is_active = 1 WHERE id = @StaffRoleId;
ELSE IF @Operation = N'REVOKE_STAFF'
    UPDATE [identity].store_assignments SET delete_date = SYSUTCDATETIME() WHERE user_id = @StaffId;
ELSE IF @Operation = N'DISABLE_OWNER_MEMBERSHIP'
    UPDATE [identity].corporate_memberships SET is_active = 0 WHERE user_id = @OwnerId;
ELSE IF @Operation = N'DISABLE_STORE'
    UPDATE catalog.stores SET is_active = 0 WHERE id = @StoreA;
ELSE IF @Operation = N'DISABLE_CORPORATE'
    UPDATE [identity].corporates SET is_active = 0 WHERE id = @CorporateA;
ELSE IF @Operation = N'CLEANUP'
BEGIN
    DELETE pts FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id WHERE pt.code LIKE @CodePrefix + N'%';
    DELETE FROM catalog.product_types WHERE code LIKE @CodePrefix + N'%';
    DELETE FROM catalog.services WHERE code LIKE @CodePrefix + N'%';
    DELETE FROM catalog.product_categories WHERE code LIKE @CodePrefix + N'%';
    DELETE FROM [identity].store_assignments WHERE user_id = @StaffId;
    DELETE FROM [identity].corporate_memberships WHERE user_id = @OwnerId;
    DELETE FROM [identity].role_permissions WHERE role_id = @StaffRoleId;
    DELETE FROM [identity].roles WHERE id = @StaffRoleId;
    DELETE FROM catalog.stores WHERE id IN (@StoreA, @StoreB);
    DELETE FROM [identity].corporates WHERE id IN (@CorporateA, @CorporateB);
    DELETE FROM [identity].user_roles WHERE user_id IN (@AdminId, @CustomerId, @StaffId, @OwnerId);
    DELETE FROM [identity].users WHERE id IN (@AdminId, @CustomerId, @StaffId, @OwnerId);
END
ELSE THROW 52300, N'Bilinmeyen test işlemi.', 1;
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
THROW;
END CATCH;

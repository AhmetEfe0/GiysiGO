IF @Operation = 'CREATE'
BEGIN
    INSERT [identity].roles(id,code,name,scope) VALUES (@RoleId,@Code,N'Offering race test','STORE');
    INSERT [identity].role_permissions(id,role_id,permission_id)
        SELECT NEWID(),@RoleId,id FROM [identity].permissions WHERE code = 'store.offering.manage';
END;
IF @Operation = 'DELETE'
BEGIN
    DELETE FROM [identity].store_assignments WHERE role_id = @RoleId;
    DELETE FROM [identity].role_permissions WHERE role_id = @RoleId;
    DELETE FROM [identity].roles WHERE id = @RoleId;
END;

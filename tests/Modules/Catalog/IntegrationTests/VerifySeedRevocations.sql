IF EXISTS (SELECT 1 FROM [identity].role_permissions rp JOIN [identity].roles r ON r.id = rp.role_id JOIN [identity].permissions p ON p.id = rp.permission_id WHERE r.code = N'StoreStaff' AND p.code = N'quote.prepare' AND rp.delete_date IS NULL)
    THROW 52301, N'Seed iptal edilmiş izni yeniden vermemelidir.', 1;
IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'StoreManager' AND is_active = 1)
    THROW 52301, N'Seed pasif rolü yeniden etkinleştirmemelidir.', 1;
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.process' AND is_active = 1)
    THROW 52301, N'Seed pasif izni yeniden etkinleştirmemelidir.', 1;

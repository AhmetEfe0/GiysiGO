SET XACT_ABORT ON;

DECLARE @Roles TABLE (code nvarchar(100) PRIMARY KEY, name nvarchar(200), scope nvarchar(30));
INSERT @Roles (code, name, scope) VALUES
    ('Customer', 'Customer', 'GLOBAL'),
    ('PlatformAdmin', 'Platform Administrator', 'GLOBAL'),
    ('CorporateOwner', 'Corporate Owner', 'CORPORATE'),
    ('StoreManager', 'Store Manager', 'STORE'),
    ('StoreStaff', 'Store Staff', 'STORE');

IF EXISTS (SELECT 1 FROM @Roles desired JOIN [identity].roles actual ON actual.code = desired.code WHERE actual.scope <> desired.scope)
    THROW 51002, 'Seed role scope conflicts with an existing role.', 1;

INSERT [identity].roles (id, code, name, scope)
SELECT NEWID(), desired.code, desired.name, desired.scope FROM @Roles desired
WHERE NOT EXISTS (SELECT 1 FROM [identity].roles actual WITH (UPDLOCK, HOLDLOCK) WHERE actual.code = desired.code);

DECLARE @Permissions TABLE (code nvarchar(100) PRIMARY KEY, description nvarchar(200));
INSERT @Permissions (code, description) VALUES
    ('store.view', 'View an authorized store'),
    ('store.staff.manage', 'Manage store staff'),
    ('store.offering.manage', 'Manage store offerings and prices'),
    ('order.view', 'View store orders'),
    ('order.inspect', 'Inspect order items'),
    ('quote.prepare', 'Prepare a price quote'),
    ('quote.approve', 'Approve and publish a price quote'),
    ('order.process', 'Process paid order items'),
    ('order.fulfill', 'Prepare an order for delivery');

INSERT [identity].permissions (id, code, description)
SELECT NEWID(), desired.code, desired.description FROM @Permissions desired
WHERE NOT EXISTS (SELECT 1 FROM [identity].permissions actual WITH (UPDLOCK, HOLDLOCK) WHERE actual.code = desired.code);

DECLARE @Grants TABLE (role_code nvarchar(100), permission_code nvarchar(100), PRIMARY KEY (role_code, permission_code));
INSERT @Grants (role_code, permission_code)
SELECT 'PlatformAdmin', code FROM @Permissions;
INSERT @Grants (role_code, permission_code)
SELECT 'CorporateOwner', code FROM @Permissions;
INSERT @Grants (role_code, permission_code)
SELECT 'StoreManager', code FROM @Permissions;
INSERT @Grants (role_code, permission_code) VALUES
    ('StoreStaff', 'store.view'),
    ('StoreStaff', 'order.view'),
    ('StoreStaff', 'order.inspect'),
    ('StoreStaff', 'quote.prepare'),
    ('StoreStaff', 'order.process');

INSERT [identity].role_permissions (id, role_id, permission_id)
SELECT NEWID(), role.id, permission.id
FROM @Grants desired
JOIN [identity].roles role ON role.code = desired.role_code
JOIN [identity].permissions permission ON permission.code = desired.permission_code
WHERE NOT EXISTS (
    SELECT 1 FROM [identity].role_permissions existing WITH (UPDLOCK, HOLDLOCK)
    WHERE existing.role_id = role.id AND existing.permission_id = permission.id
);

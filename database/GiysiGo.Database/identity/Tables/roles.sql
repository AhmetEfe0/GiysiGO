-- identity.roles
CREATE TABLE [identity].roles (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    code nvarchar(100) NOT NULL UNIQUE,
    name nvarchar(200) NOT NULL,
    scope nvarchar(30) NOT NULL CHECK (scope IN ('GLOBAL', 'CORPORATE', 'STORE')),
    is_active bit NOT NULL DEFAULT 1,
    UNIQUE (id, scope)
);
GO

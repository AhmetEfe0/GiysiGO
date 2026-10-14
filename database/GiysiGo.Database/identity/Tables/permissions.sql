-- identity.permissions
CREATE TABLE [identity].permissions (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    code nvarchar(100) NOT NULL UNIQUE,
    description nvarchar(max) NOT NULL,
    is_active bit NOT NULL DEFAULT 1
);
GO

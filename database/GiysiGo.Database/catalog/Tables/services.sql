-- catalog.services
CREATE TABLE [catalog].services (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    code nvarchar(100) NOT NULL UNIQUE,
    name nvarchar(200) NOT NULL,
    is_active bit NOT NULL DEFAULT 1
);
GO

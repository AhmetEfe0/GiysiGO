-- identity.corporates
CREATE TABLE [identity].corporates (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    name nvarchar(200) NOT NULL,
    is_active bit NOT NULL DEFAULT 1,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

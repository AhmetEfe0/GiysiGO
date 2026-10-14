-- identity.users
CREATE TABLE [identity].users (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    email nvarchar(320) COLLATE Latin1_General_100_CI_AS NOT NULL,
    password_hash nvarchar(max) NOT NULL,
    is_active bit NOT NULL DEFAULT 1,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    CHECK (LEN(LTRIM(RTRIM(email))) > 3)
);
GO
CREATE UNIQUE INDEX ux_users_email_ci ON [identity].users (email) WHERE delete_date IS NULL;
GO

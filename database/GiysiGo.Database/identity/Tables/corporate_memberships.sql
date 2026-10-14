-- identity.corporate_memberships
CREATE TABLE [identity].corporate_memberships (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    user_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    corporate_id uniqueidentifier NOT NULL REFERENCES [identity].corporates(id),
    role_id uniqueidentifier NOT NULL,
    role_scope nvarchar(30) NOT NULL DEFAULT 'CORPORATE' CHECK (role_scope = 'CORPORATE'),
    is_active bit NOT NULL DEFAULT 1,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),

    FOREIGN KEY (role_id, role_scope) REFERENCES [identity].roles(id, scope)
);
GO
CREATE UNIQUE INDEX ux_corporate_memberships_live ON [identity].corporate_memberships (user_id, corporate_id, role_id) WHERE delete_date IS NULL;
GO
CREATE INDEX ix_corporate_memberships_corporate ON [identity].corporate_memberships (corporate_id) WHERE is_active = 1;
GO

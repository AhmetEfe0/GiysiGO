-- identity.user_roles
CREATE TABLE [identity].user_roles (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    user_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    role_id uniqueidentifier NOT NULL,
    role_scope nvarchar(30) NOT NULL DEFAULT 'GLOBAL' CHECK (role_scope = 'GLOBAL'),

    FOREIGN KEY (role_id, role_scope) REFERENCES [identity].roles(id, scope)
);
GO
CREATE UNIQUE INDEX ux_user_roles_live ON [identity].user_roles (user_id, role_id) WHERE delete_date IS NULL;
GO

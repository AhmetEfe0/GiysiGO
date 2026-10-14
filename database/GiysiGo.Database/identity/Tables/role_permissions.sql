-- identity.role_permissions
CREATE TABLE [identity].role_permissions (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    role_id uniqueidentifier NOT NULL REFERENCES [identity].roles(id),
    permission_id uniqueidentifier NOT NULL REFERENCES [identity].permissions(id)
);
GO
CREATE UNIQUE INDEX ux_role_permissions_live ON [identity].role_permissions (role_id, permission_id) WHERE delete_date IS NULL;
GO

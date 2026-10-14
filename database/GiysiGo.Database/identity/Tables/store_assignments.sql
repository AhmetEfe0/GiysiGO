-- identity.store_assignments
CREATE TABLE [identity].store_assignments (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    user_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    store_id uniqueidentifier NOT NULL REFERENCES [catalog].stores(id),
    role_id uniqueidentifier NOT NULL,
    role_scope nvarchar(30) NOT NULL DEFAULT 'STORE' CHECK (role_scope = 'STORE'),
    is_active bit NOT NULL DEFAULT 1,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),

    FOREIGN KEY (role_id, role_scope) REFERENCES [identity].roles(id, scope)
);
GO
CREATE UNIQUE INDEX ux_store_assignments_live ON [identity].store_assignments (user_id, store_id, role_id) WHERE delete_date IS NULL;
GO
CREATE INDEX ix_store_assignments_store ON [identity].store_assignments (store_id) WHERE is_active = 1;
GO

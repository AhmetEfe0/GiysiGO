CREATE TABLE [identity].auth_sessions (
    id uniqueidentifier NOT NULL PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7) NULL,
    delete_date datetime2(7) NULL,
    user_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    token_hash binary(32) NOT NULL,
    expires_at_utc datetime2(7) NOT NULL,
    revoked_at_utc datetime2(7) NULL,
    replaced_by_id uniqueidentifier NULL,
    CONSTRAINT ck_auth_sessions_expiry CHECK (expires_at_utc > create_date)
);
GO
CREATE UNIQUE INDEX ux_auth_sessions_token_hash ON [identity].auth_sessions(token_hash);
GO
CREATE INDEX ix_auth_sessions_user ON [identity].auth_sessions(user_id, expires_at_utc);
GO

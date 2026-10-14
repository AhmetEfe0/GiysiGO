-- building_blocks.outbox_messages
CREATE TABLE [building_blocks].outbox_messages (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    event_type nvarchar(60) NOT NULL,
    aggregate_id uniqueidentifier NOT NULL,
    payload nvarchar(max) NOT NULL CHECK (ISJSON(payload) = 1),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    processed_at datetime2(7),
    attempt_count int NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
    last_error nvarchar(max)
);
GO
CREATE INDEX ix_outbox_unprocessed ON [building_blocks].outbox_messages (create_date)
    WHERE processed_at IS NULL;
GO

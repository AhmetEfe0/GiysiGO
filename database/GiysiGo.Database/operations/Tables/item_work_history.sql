-- operations.item_work_history
CREATE TABLE [operations].item_work_history (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    item_work_id uniqueidentifier NOT NULL REFERENCES [operations].item_work(id),
    from_status nvarchar(40),
    to_status nvarchar(40) NOT NULL,
    actor_user_id uniqueidentifier REFERENCES [identity].users(id),
    note nvarchar(max),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_item_work_history_work ON [operations].item_work_history (item_work_id, create_date);
GO

-- operations.delivery_events
CREATE TABLE [operations].delivery_events (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    delivery_task_id uniqueidentifier NOT NULL REFERENCES [operations].delivery_tasks(id),
    event_type nvarchar(60) NOT NULL CHECK (event_type IN (
        'ASSIGNED', 'PICKED_UP', 'AT_STORE', 'OUT_FOR_DELIVERY', 'DELIVERED',
        'RETURN_IN_TRANSIT', 'RETURNED', 'CANCELLED')),
    source nvarchar(40) NOT NULL CHECK (source IN ('MOCK', 'COURIER', 'STORE', 'SYSTEM')),
    actor_user_id uniqueidentifier REFERENCES [identity].users(id),
    occurred_at datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    note nvarchar(max)
);
GO
CREATE INDEX ix_delivery_events_task ON [operations].delivery_events (delivery_task_id, occurred_at);
GO

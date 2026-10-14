-- ordering.order_status_history
CREATE TABLE [ordering].order_status_history (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    order_id uniqueidentifier NOT NULL REFERENCES [ordering].orders(id),
    from_status nvarchar(40),
    to_status nvarchar(40) NOT NULL,
    actor_user_id uniqueidentifier REFERENCES [identity].users(id),
    source nvarchar(40) NOT NULL CHECK (source IN ('CUSTOMER', 'STORE', 'SYSTEM', 'MOCK_COURIER', 'PAYMENT_PROVIDER')),
    note nvarchar(max),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_order_status_history_order ON [ordering].order_status_history (order_id, create_date);
GO

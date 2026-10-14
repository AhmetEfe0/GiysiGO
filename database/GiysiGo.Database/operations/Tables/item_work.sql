-- operations.item_work
CREATE TABLE [operations].item_work (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    order_item_service_id uniqueidentifier NOT NULL UNIQUE REFERENCES [ordering].order_item_services(id),
    status nvarchar(40) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED')),
    started_at datetime2(7),
    completed_at datetime2(7),
    CHECK (completed_at IS NULL OR started_at IS NOT NULL)
);
GO

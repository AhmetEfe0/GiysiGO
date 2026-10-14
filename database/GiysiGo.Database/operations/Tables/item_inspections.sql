-- operations.item_inspections
CREATE TABLE [operations].item_inspections (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    order_item_id uniqueidentifier NOT NULL UNIQUE REFERENCES [ordering].order_items(id),
    status nvarchar(40) NOT NULL CHECK (status IN ('ACCEPTED', 'REJECTED')),
    findings nvarchar(max),
    inspected_by uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    inspected_at datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

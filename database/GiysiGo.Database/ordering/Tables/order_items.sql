-- ordering.order_items
CREATE TABLE [ordering].order_items (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    order_id uniqueidentifier NOT NULL REFERENCES [ordering].orders(id),
    product_type_id uniqueidentifier NOT NULL REFERENCES [catalog].product_types(id),
    product_type_name_snapshot nvarchar(200) NOT NULL,
    customer_note nvarchar(max),
    customer_measurement decimal(12,3) CHECK (customer_measurement > 0),
    verified_measurement decimal(12,3) CHECK (verified_measurement > 0),
    tracking_code nvarchar(100) NOT NULL UNIQUE,
    inspection_status nvarchar(max) NOT NULL DEFAULT 'PENDING' CHECK (inspection_status IN ('PENDING', 'ACCEPTED', 'REJECTED')),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    UNIQUE (id, product_type_id)
);
GO
CREATE INDEX ix_order_items_order ON [ordering].order_items (order_id);
GO

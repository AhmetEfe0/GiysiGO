-- ordering.order_item_services
CREATE TABLE [ordering].order_item_services (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    order_item_id uniqueidentifier NOT NULL REFERENCES [ordering].order_items(id),
    product_type_service_id uniqueidentifier NOT NULL REFERENCES [catalog].product_type_services(id),
    service_name_snapshot nvarchar(200) NOT NULL,
    estimated_unit_price decimal(12,2) NOT NULL CHECK (estimated_unit_price >= 0),
    price_unit_snapshot nvarchar(20) NOT NULL CHECK (price_unit_snapshot IN ('PIECE', 'M2')),
    estimated_quantity decimal(12,3) NOT NULL CHECK (estimated_quantity > 0),
    estimated_price decimal(12,2) NOT NULL CHECK (estimated_price >= 0),
    status nvarchar(40) NOT NULL DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'APPROVED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    UNIQUE (order_item_id, product_type_service_id)
);
GO
CREATE INDEX ix_order_item_services_item ON [ordering].order_item_services (order_item_id);
GO

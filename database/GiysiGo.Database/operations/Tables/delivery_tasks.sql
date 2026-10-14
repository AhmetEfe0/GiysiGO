-- operations.delivery_tasks
CREATE TABLE [operations].delivery_tasks (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    order_id uniqueidentifier NOT NULL REFERENCES [ordering].orders(id),
    task_type nvarchar(40) NOT NULL CHECK (task_type IN ('CUSTOMER_PICKUP', 'CUSTOMER_DELIVERY', 'REJECTED_ORDER_RETURN')),
    status nvarchar(40) NOT NULL DEFAULT 'PENDING_ASSIGNMENT' CHECK (status IN (
        'PENDING_ASSIGNMENT', 'ASSIGNED', 'IN_TRANSIT', 'COMPLETED', 'CANCELLED')),
    origin_address_snapshot nvarchar(max) NOT NULL,
    origin_latitude decimal(9,6) NOT NULL CHECK (origin_latitude BETWEEN -90 AND 90),
    origin_longitude decimal(9,6) NOT NULL CHECK (origin_longitude BETWEEN -180 AND 180),
    destination_address_snapshot nvarchar(max) NOT NULL,
    destination_latitude decimal(9,6) NOT NULL CHECK (destination_latitude BETWEEN -90 AND 90),
    destination_longitude decimal(9,6) NOT NULL CHECK (destination_longitude BETWEEN -180 AND 180),
    requested_window_start datetime2(7) NOT NULL,
    requested_window_end datetime2(7) NOT NULL,
    required_capacity_units int NOT NULL CHECK (required_capacity_units > 0),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    CHECK (requested_window_end > requested_window_start)
);
GO
CREATE UNIQUE INDEX ux_delivery_tasks_one_open_type_per_order
    ON [operations].delivery_tasks (order_id, task_type)
    WHERE status IN ('PENDING_ASSIGNMENT', 'ASSIGNED', 'IN_TRANSIT');
GO
CREATE INDEX ix_delivery_tasks_pending ON [operations].delivery_tasks (requested_window_start)
    WHERE status = 'PENDING_ASSIGNMENT';
GO

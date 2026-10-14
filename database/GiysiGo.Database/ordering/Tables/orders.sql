-- ordering.orders
CREATE TABLE [ordering].orders (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    source_cart_id uniqueidentifier NOT NULL UNIQUE REFERENCES [ordering].carts(id),
    customer_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    store_id uniqueidentifier NOT NULL REFERENCES [catalog].stores(id),
    pickup_window_start datetime2(7) NOT NULL,
    pickup_window_end datetime2(7) NOT NULL,
    status nvarchar(40) NOT NULL DEFAULT 'AWAITING_PICKUP_ASSIGNMENT' CHECK (status IN (
        'AWAITING_PICKUP_ASSIGNMENT', 'PICKUP_ASSIGNED', 'PICKED_UP', 'AT_STORE',
        'INSPECTING', 'AWAITING_STORE_APPROVAL', 'AWAITING_CUSTOMER_APPROVAL',
        'AWAITING_PAYMENT', 'PROCESSING', 'READY_FOR_DELIVERY', 'DELIVERY_ASSIGNED',
        'OUT_FOR_DELIVERY', 'DELIVERED', 'RETURN_REQUESTED', 'RETURN_ASSIGNED',
        'RETURN_IN_TRANSIT', 'RETURNED', 'CANCELLED')),
    estimated_total decimal(12,2) NOT NULL CHECK (estimated_total >= 0),
    currency char(3) NOT NULL DEFAULT 'TRY' CHECK (currency = 'TRY'),
    idempotency_key nvarchar(200) NOT NULL,
    version int NOT NULL DEFAULT 0 CHECK (version >= 0),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    CHECK (pickup_window_end > pickup_window_start),
    UNIQUE (customer_id, idempotency_key)
);
GO
CREATE INDEX ix_orders_store_status ON [ordering].orders (store_id, status, create_date DESC);
GO
CREATE INDEX ix_orders_customer ON [ordering].orders (customer_id, create_date DESC);
GO

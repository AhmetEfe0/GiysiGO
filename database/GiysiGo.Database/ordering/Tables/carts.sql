-- ordering.carts
CREATE TABLE [ordering].carts (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    customer_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    store_id uniqueidentifier NOT NULL REFERENCES [catalog].stores(id),
    address_id uniqueidentifier NOT NULL REFERENCES [identity].customer_addresses(id),
    pickup_window_start datetime2(7),
    pickup_window_end datetime2(7),
    status nvarchar(40) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CHECKED_OUT', 'ABANDONED')),
    version int NOT NULL DEFAULT 0 CHECK (version >= 0),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    CHECK ((pickup_window_start IS NULL AND pickup_window_end IS NULL)
        OR (pickup_window_start IS NOT NULL AND pickup_window_end > pickup_window_start)),
    UNIQUE (id, store_id)
);
GO
CREATE UNIQUE INDEX ux_carts_one_open_per_customer_store
    ON [ordering].carts (customer_id, store_id) WHERE status = 'OPEN';
GO

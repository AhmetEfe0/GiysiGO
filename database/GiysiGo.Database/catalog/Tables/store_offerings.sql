-- catalog.store_offerings
CREATE TABLE [catalog].store_offerings (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    delete_date datetime2(7),
    store_id uniqueidentifier NOT NULL REFERENCES [catalog].stores(id),
    product_type_service_id uniqueidentifier NOT NULL REFERENCES [catalog].product_type_services(id),
    price_override decimal(12,2) CHECK (price_override >= 0),
    is_active bit NOT NULL DEFAULT 1,
    update_date datetime2(7),
    UNIQUE (store_id, product_type_service_id),
    UNIQUE (id, store_id)
);
GO
CREATE INDEX ix_store_offerings_service ON [catalog].store_offerings (product_type_service_id) WHERE is_active = 1;
GO

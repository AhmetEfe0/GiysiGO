-- catalog.product_type_services
CREATE TABLE [catalog].product_type_services (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    product_type_id uniqueidentifier NOT NULL REFERENCES [catalog].product_types(id),
    service_id uniqueidentifier NOT NULL REFERENCES [catalog].services(id),
    default_price decimal(12,2) NOT NULL CHECK (default_price >= 0),
    currency char(3) NOT NULL DEFAULT 'TRY' CHECK (currency = 'TRY'),
    price_unit nvarchar(20) NOT NULL CHECK (price_unit IN ('PIECE', 'M2')),
    selection_kind nvarchar(30) NOT NULL CHECK (selection_kind IN ('BASE', 'ALTERNATIVE', 'ADD_ON')),
    is_default_selected bit NOT NULL DEFAULT 0,
    is_active bit NOT NULL DEFAULT 1,
    UNIQUE (product_type_id, service_id),
    UNIQUE (id, product_type_id)
);
GO
CREATE UNIQUE INDEX ux_product_type_services_default
    ON [catalog].product_type_services (product_type_id) WHERE is_default_selected = 1;
GO
CREATE INDEX ix_product_type_services_service ON [catalog].product_type_services (service_id) WHERE is_active = 1;
GO

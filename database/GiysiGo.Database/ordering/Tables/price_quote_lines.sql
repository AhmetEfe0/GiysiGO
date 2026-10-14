-- ordering.price_quote_lines
CREATE TABLE [ordering].price_quote_lines (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    price_quote_id uniqueidentifier NOT NULL REFERENCES [ordering].price_quotes(id),
    order_item_service_id uniqueidentifier NOT NULL REFERENCES [ordering].order_item_services(id),
    service_name_snapshot nvarchar(200) NOT NULL,
    unit_price decimal(12,2) NOT NULL CHECK (unit_price >= 0),
    price_unit nvarchar(20) NOT NULL CHECK (price_unit IN ('PIECE', 'M2')),
    quantity decimal(12,3) NOT NULL CHECK (quantity > 0),
    amount decimal(12,2) NOT NULL CHECK (amount >= 0),
    explanation nvarchar(max),
    UNIQUE (price_quote_id, order_item_service_id)
);
GO
CREATE INDEX ix_price_quote_lines_quote ON [ordering].price_quote_lines (price_quote_id);
GO

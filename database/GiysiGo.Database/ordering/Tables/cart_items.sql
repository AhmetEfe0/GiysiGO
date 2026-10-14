-- ordering.cart_items
CREATE TABLE [ordering].cart_items (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    cart_id uniqueidentifier NOT NULL REFERENCES [ordering].carts(id) ON DELETE CASCADE,
    product_type_id uniqueidentifier NOT NULL REFERENCES [catalog].product_types(id),
    customer_note nvarchar(max),
    customer_measurement decimal(12,3) CHECK (customer_measurement > 0),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    UNIQUE (id, product_type_id)
);
GO
CREATE INDEX ix_cart_items_cart ON [ordering].cart_items (cart_id);
GO

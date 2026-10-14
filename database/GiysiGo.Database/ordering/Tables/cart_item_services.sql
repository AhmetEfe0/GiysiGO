-- ordering.cart_item_services
CREATE TABLE [ordering].cart_item_services (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    cart_item_id uniqueidentifier NOT NULL REFERENCES [ordering].cart_items(id) ON DELETE CASCADE,
    store_offering_id uniqueidentifier NOT NULL REFERENCES [catalog].store_offerings(id)
);
GO
CREATE UNIQUE INDEX ux_cart_item_services_live ON [ordering].cart_item_services (cart_item_id, store_offering_id) WHERE delete_date IS NULL;
GO

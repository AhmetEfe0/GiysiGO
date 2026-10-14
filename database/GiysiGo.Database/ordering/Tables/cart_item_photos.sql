-- ordering.cart_item_photos
CREATE TABLE [ordering].cart_item_photos (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    cart_item_id uniqueidentifier NOT NULL REFERENCES [ordering].cart_items(id) ON DELETE CASCADE,
    storage_key nvarchar(1024) NOT NULL,
    photo_type nvarchar(40) NOT NULL,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_cart_item_photos_item ON [ordering].cart_item_photos (cart_item_id);
GO

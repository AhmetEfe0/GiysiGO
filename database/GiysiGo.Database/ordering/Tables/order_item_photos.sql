-- ordering.order_item_photos
CREATE TABLE [ordering].order_item_photos (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    order_item_id uniqueidentifier NOT NULL REFERENCES [ordering].order_items(id),
    storage_key nvarchar(1024) NOT NULL,
    photo_type nvarchar(40) NOT NULL,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_order_item_photos_item ON [ordering].order_item_photos (order_item_id);
GO

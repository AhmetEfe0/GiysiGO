DECLARE @CartId uniqueidentifier = NEWID();
DECLARE @OrderId uniqueidentifier = NEWID();
DECLARE @SnapshotId uniqueidentifier = NEWID();
INSERT [ordering].carts (id, customer_id, store_id, address_id, status)
VALUES (@CartId, @CustomerId, @StoreId, @AddressId, 'CHECKED_OUT');
INSERT [ordering].orders (id, source_cart_id, customer_id, store_id, pickup_window_start,
    pickup_window_end, estimated_total, currency, idempotency_key)
VALUES (@OrderId, @CartId, @CustomerId, @StoreId, DATEADD(hour, 1, SYSUTCDATETIME()),
    DATEADD(hour, 2, SYSUTCDATETIME()), 200, 'TRY', CONVERT(nvarchar(36), @OrderId));
INSERT [ordering].order_address_snapshots (id, order_id, address_text, latitude, longitude,
    contact_name, contact_phone)
VALUES (@SnapshotId, @OrderId, @AddressText, @Latitude, @Longitude, @ContactName, @ContactPhone);
SELECT @SnapshotId;

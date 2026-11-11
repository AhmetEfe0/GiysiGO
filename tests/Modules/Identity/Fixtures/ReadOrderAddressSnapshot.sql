SELECT address_text AS AddressText, latitude AS Latitude, longitude AS Longitude,
    contact_name AS ContactName, contact_phone AS ContactPhone
FROM [ordering].order_address_snapshots WHERE id = @SnapshotId;

-- ordering.order_address_snapshots
CREATE TABLE [ordering].order_address_snapshots (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    order_id uniqueidentifier NOT NULL UNIQUE REFERENCES [ordering].orders(id),
    address_text nvarchar(max) NOT NULL,
    latitude decimal(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude decimal(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    contact_name nvarchar(200) NOT NULL,
    contact_phone nvarchar(30) NOT NULL
);
GO

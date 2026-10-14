-- identity.customer_addresses
CREATE TABLE [identity].customer_addresses (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    user_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    label nvarchar(100) NOT NULL,
    address_text nvarchar(max) NOT NULL,
    latitude decimal(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude decimal(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    contact_name nvarchar(200) NOT NULL,
    contact_phone nvarchar(30) NOT NULL,
    is_active bit NOT NULL DEFAULT 1,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_customer_addresses_user ON [identity].customer_addresses (user_id) WHERE is_active = 1;
GO

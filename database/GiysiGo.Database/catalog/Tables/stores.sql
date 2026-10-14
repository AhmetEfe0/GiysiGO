-- catalog.stores
CREATE TABLE [catalog].stores (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    corporate_id uniqueidentifier NOT NULL REFERENCES [identity].corporates(id),
    name nvarchar(200) NOT NULL,
    address_text nvarchar(max) NOT NULL,
    latitude decimal(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude decimal(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    service_radius_km decimal(7,2) NOT NULL CHECK (service_radius_km > 0),
    is_active bit NOT NULL DEFAULT 1,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_stores_corporate ON [catalog].stores (corporate_id) WHERE is_active = 1;
GO

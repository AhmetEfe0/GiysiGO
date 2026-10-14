-- operations.courier_availability
CREATE TABLE [operations].courier_availability (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    courier_id uniqueidentifier NOT NULL REFERENCES [operations].courier_profiles(id),
    starts_at datetime2(7) NOT NULL,
    ends_at datetime2(7) NOT NULL,
    status nvarchar(40) NOT NULL CHECK (status IN ('AVAILABLE', 'UNAVAILABLE')),
    CHECK (ends_at > starts_at)
);
GO
CREATE INDEX ix_courier_availability_courier_time
    ON [operations].courier_availability (courier_id, starts_at, ends_at);
GO

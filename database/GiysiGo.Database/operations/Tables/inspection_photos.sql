-- operations.inspection_photos
CREATE TABLE [operations].inspection_photos (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    inspection_id uniqueidentifier NOT NULL REFERENCES [operations].item_inspections(id),
    storage_key nvarchar(1024) NOT NULL,
    photo_type nvarchar(40) NOT NULL,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_inspection_photos_inspection ON [operations].inspection_photos (inspection_id);
GO

-- catalog.product_types
CREATE TABLE [catalog].product_types (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    category_id uniqueidentifier NOT NULL REFERENCES [catalog].product_categories(id),
    code nvarchar(100) NOT NULL UNIQUE,
    name nvarchar(200) NOT NULL,
    base_unit nvarchar(20) NOT NULL CHECK (base_unit IN ('PIECE', 'M2')),
    is_active bit NOT NULL DEFAULT 1
);
GO
CREATE INDEX ix_product_types_category ON [catalog].product_types (category_id) WHERE is_active = 1;
GO

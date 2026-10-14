-- catalog.product_categories
CREATE TABLE [catalog].product_categories (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    code nvarchar(100) NOT NULL UNIQUE,
    name nvarchar(200) NOT NULL,
    sort_order int NOT NULL DEFAULT 0,
    is_active bit NOT NULL DEFAULT 1
);
GO

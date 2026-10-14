-- ordering.price_quotes
CREATE TABLE [ordering].price_quotes (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    order_id uniqueidentifier NOT NULL REFERENCES [ordering].orders(id),
    revision int NOT NULL CHECK (revision > 0),
    status nvarchar(40) NOT NULL DEFAULT 'DRAFT' CHECK (status IN (
        'DRAFT', 'PENDING_STORE_APPROVAL', 'PUBLISHED', 'CUSTOMER_ACCEPTED',
        'CUSTOMER_REJECTED', 'SUPERSEDED', 'EXPIRED')),
    subtotal decimal(12,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    pickup_fee decimal(12,2) NOT NULL DEFAULT 0 CHECK (pickup_fee >= 0),
    delivery_fee decimal(12,2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
    total_amount decimal(12,2) NOT NULL CHECK (total_amount >= 0),
    currency char(3) NOT NULL DEFAULT 'TRY' CHECK (currency = 'TRY'),
    expires_at datetime2(7),
    customer_decision_by uniqueidentifier REFERENCES [identity].users(id),
    customer_decision_at datetime2(7),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    UNIQUE (order_id, revision),
    CHECK ((customer_decision_by IS NULL AND customer_decision_at IS NULL) OR (customer_decision_by IS NOT NULL AND customer_decision_at IS NOT NULL))
);
GO
CREATE UNIQUE INDEX ux_price_quotes_one_current
    ON [ordering].price_quotes (order_id)
    WHERE status IN ('DRAFT', 'PENDING_STORE_APPROVAL', 'PUBLISHED', 'CUSTOMER_ACCEPTED');
GO

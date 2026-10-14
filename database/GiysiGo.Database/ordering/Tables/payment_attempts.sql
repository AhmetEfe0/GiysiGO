-- ordering.payment_attempts
CREATE TABLE [ordering].payment_attempts (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    order_id uniqueidentifier NOT NULL REFERENCES [ordering].orders(id),
    price_quote_id uniqueidentifier NOT NULL REFERENCES [ordering].price_quotes(id),
    provider nvarchar(60) NOT NULL,
    provider_payment_id nvarchar(200),
    idempotency_key nvarchar(200) NOT NULL,
    amount decimal(12,2) NOT NULL CHECK (amount >= 0),
    currency char(3) NOT NULL DEFAULT 'TRY' CHECK (currency = 'TRY'),
    status nvarchar(40) NOT NULL DEFAULT 'INITIATED' CHECK (status IN ('INITIATED', 'SUCCEEDED', 'FAILED', 'CANCELLED')),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    completed_at datetime2(7),
    UNIQUE (provider, idempotency_key)
);
GO
CREATE UNIQUE INDEX ux_payment_attempt_provider_id
    ON [ordering].payment_attempts (provider, provider_payment_id)
    WHERE provider_payment_id IS NOT NULL;
GO
CREATE UNIQUE INDEX ux_payment_one_success_per_order
    ON [ordering].payment_attempts (order_id) WHERE status = 'SUCCEEDED';
GO
CREATE INDEX ix_payment_attempts_order ON [ordering].payment_attempts (order_id, create_date DESC);
GO

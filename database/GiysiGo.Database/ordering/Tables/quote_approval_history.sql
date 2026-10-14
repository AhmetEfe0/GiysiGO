-- ordering.quote_approval_history
CREATE TABLE [ordering].quote_approval_history (
    id uniqueidentifier PRIMARY KEY,
    update_date datetime2(7),
    delete_date datetime2(7),
    price_quote_id uniqueidentifier NOT NULL REFERENCES [ordering].price_quotes(id),
    action nvarchar(30) NOT NULL CHECK (action IN ('SUBMITTED', 'APPROVED', 'REJECTED', 'PUBLISHED')),
    actor_user_id uniqueidentifier NOT NULL REFERENCES [identity].users(id),
    reason nvarchar(max),
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX ix_quote_approval_history_quote ON [ordering].quote_approval_history (price_quote_id, create_date);
GO

CREATE PROCEDURE [building_blocks].[spMarkOutboxMessageProcessed]
    @Id uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [building_blocks].outbox_messages
    SET processed_at = SYSUTCDATETIME(),
        update_date = SYSUTCDATETIME(),
        attempt_count = attempt_count + 1,
        last_error = NULL
    WHERE id = @Id AND processed_at IS NULL;

    IF @@ROWCOUNT <> 1
        THROW 51000, 'Outbox message was not marked processed.', 1;
END;

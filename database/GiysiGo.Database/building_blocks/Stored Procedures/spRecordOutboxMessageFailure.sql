CREATE PROCEDURE [building_blocks].[spRecordOutboxMessageFailure]
    @Id uniqueidentifier,
    @Error nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [building_blocks].outbox_messages
    SET attempt_count = attempt_count + 1,
        last_error = @Error,
        update_date = SYSUTCDATETIME()
    WHERE id = @Id AND processed_at IS NULL;
END;

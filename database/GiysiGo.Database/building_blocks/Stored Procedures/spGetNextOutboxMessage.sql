CREATE PROCEDURE [building_blocks].[spGetNextOutboxMessage]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        id AS Id,
        event_type AS EventType,
        payload AS Payload
    FROM [building_blocks].outbox_messages WITH (UPDLOCK, READPAST, ROWLOCK)
    WHERE processed_at IS NULL AND delete_date IS NULL
    ORDER BY create_date, id;
END;

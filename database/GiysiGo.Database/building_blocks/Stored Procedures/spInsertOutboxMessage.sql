CREATE PROCEDURE [building_blocks].[spInsertOutboxMessage]
    @Id uniqueidentifier,
    @EventType nvarchar(60),
    @AggregateId uniqueidentifier,
    @Payload nvarchar(max),
    @CreateDate datetime2(7)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [building_blocks].outbox_messages
        (id, event_type, aggregate_id, payload, create_date)
    VALUES
        (@Id, @EventType, @AggregateId, @Payload, @CreateDate);
END;

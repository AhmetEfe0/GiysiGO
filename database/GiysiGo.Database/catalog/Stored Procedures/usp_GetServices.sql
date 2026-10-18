CREATE PROCEDURE [catalog].[usp_GetServices]
    @include_inactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [id] AS Id,
        [code] AS Code,
        [name] AS Name,
        [is_active] AS IsActive,
        [create_date] AS CreateDate,
        [update_date] AS UpdateDate,
        [delete_date] AS DeleteDate
    FROM [catalog].[services]
    WHERE [delete_date] IS NULL
      AND (@include_inactive = 1 OR [is_active] = 1)
    ORDER BY [name] ASC, [id] ASC;
END
GO
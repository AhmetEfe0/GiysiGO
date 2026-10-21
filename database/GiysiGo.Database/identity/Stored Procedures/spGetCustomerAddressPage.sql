CREATE PROCEDURE [identity].[spGetCustomerAddressPage]
    @UserId uniqueidentifier,
    @Page int,
    @PageSize int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Page IS NULL OR @Page < 1 OR @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 100
        THROW 51002, 'Page must be positive and page size must be 1 to 100.', 1;

    DECLARE @Offset bigint = (CONVERT(bigint, @Page) - 1) * @PageSize;

    SELECT COUNT(*) AS TotalCount
    FROM [identity].customer_addresses a
    WHERE a.user_id = @UserId AND a.delete_date IS NULL AND a.is_active = 1
      AND EXISTS (SELECT 1 FROM [identity].users u
                  WHERE u.id = @UserId AND u.delete_date IS NULL AND u.is_active = 1);

    SELECT a.id AS Id, a.create_date AS CreateDate, a.update_date AS UpdateDate,
           a.delete_date AS DeleteDate, a.user_id AS UserId, a.label AS Label,
           a.address_text AS AddressText, a.latitude AS Latitude,
           a.longitude AS Longitude, a.contact_name AS ContactName,
           a.contact_phone AS ContactPhone, a.is_active AS IsActive
    FROM [identity].customer_addresses a
    WHERE a.user_id = @UserId AND a.delete_date IS NULL AND a.is_active = 1
      AND EXISTS (SELECT 1 FROM [identity].users u
                  WHERE u.id = @UserId AND u.delete_date IS NULL AND u.is_active = 1)
    ORDER BY a.create_date, a.id
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

CREATE PROCEDURE [identity].[spGetStaffMembers]
    @CorporateId uniqueidentifier, @StoreId uniqueidentifier=NULL, @Page int=1, @PageSize int=20
AS
BEGIN
    SET NOCOUNT ON;
    IF @Page IS NULL OR @Page<1 OR @PageSize IS NULL OR @PageSize NOT BETWEEN 1 AND 100
        THROW 51002, 'Invalid pagination.', 1;
    SELECT m.user_id AS UserId,m.role_id AS RoleId,r.code AS RoleCode
    INTO #Members
    FROM (
        SELECT user_id,role_id FROM [identity].corporate_memberships
        WHERE @StoreId IS NULL AND corporate_id=@CorporateId AND is_active=1 AND delete_date IS NULL
        UNION ALL
        SELECT user_id,role_id FROM [identity].store_assignments
        WHERE @StoreId IS NOT NULL AND store_id=@StoreId AND is_active=1 AND delete_date IS NULL
    ) m
    JOIN [identity].users u ON u.id=m.user_id AND u.is_active=1 AND u.delete_date IS NULL
    JOIN [identity].roles r ON r.id=m.role_id AND r.is_active=1 AND r.delete_date IS NULL
    WHERE EXISTS (SELECT 1 FROM [identity].corporates WHERE id=@CorporateId AND is_active=1 AND delete_date IS NULL);
    SELECT COUNT_BIG(*) AS TotalCount FROM #Members;
    SELECT UserId,RoleId,RoleCode FROM #Members ORDER BY UserId,RoleId
    OFFSET ((CONVERT(bigint,@Page)-1)*@PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

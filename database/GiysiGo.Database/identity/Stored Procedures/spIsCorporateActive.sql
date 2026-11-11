CREATE PROCEDURE [identity].[spIsCorporateActive] @CorporateId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    -- Karar, çağıranın transaction'ı bitene kadar şirket değişikliğine karşı korunur.
    SELECT CAST(CASE WHEN EXISTS (
        SELECT 1 FROM [identity].corporates WITH (HOLDLOCK)
        WHERE id = @CorporateId AND is_active = 1 AND delete_date IS NULL
    ) THEN 1 ELSE 0 END AS bit);
END;
GO

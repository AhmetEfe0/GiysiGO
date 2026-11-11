CREATE PROCEDURE [ordering].[spGetCartItemCatalogContext]
    @CartItemId uniqueidentifier, @CustomerId uniqueidentifier, @ExpectedCartVersion int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.store_id AS StoreId, ci.product_type_id AS ProductTypeId
    FROM [ordering].cart_items ci
    INNER JOIN [ordering].carts c WITH (UPDLOCK, HOLDLOCK) ON c.id = ci.cart_id
    WHERE ci.id = @CartItemId AND ci.delete_date IS NULL
      AND c.customer_id = @CustomerId AND c.status = 'OPEN' AND c.delete_date IS NULL
      AND c.version = @ExpectedCartVersion;
END;
GO

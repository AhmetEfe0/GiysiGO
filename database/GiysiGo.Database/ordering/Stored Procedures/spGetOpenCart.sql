CREATE PROCEDURE [ordering].[spGetOpenCart]
    @CartId uniqueidentifier,
    @CustomerId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.id AS Id, c.create_date AS CreateDate, c.update_date AS UpdateDate,
           c.delete_date AS DeleteDate, c.customer_id AS CustomerId, c.store_id AS StoreId,
           c.address_id AS AddressId, c.pickup_window_start AS PickupWindowStart,
           c.pickup_window_end AS PickupWindowEnd, c.status AS Status, c.version AS Version
    FROM [ordering].carts c
    WHERE c.id = @CartId AND c.customer_id = @CustomerId AND c.status = 'OPEN' AND c.delete_date IS NULL;

    SELECT ci.id AS Id, ci.create_date AS CreateDate, ci.update_date AS UpdateDate,
           ci.delete_date AS DeleteDate, ci.cart_id AS CartId, ci.product_type_id AS ProductTypeId,
           ci.customer_note AS CustomerNote, ci.customer_measurement AS CustomerMeasurement
    FROM [ordering].cart_items ci
    INNER JOIN [ordering].carts c ON c.id = ci.cart_id
    WHERE c.id = @CartId AND c.customer_id = @CustomerId AND c.status = 'OPEN' AND c.delete_date IS NULL
      AND ci.delete_date IS NULL
    ORDER BY ci.create_date, ci.id;

    SELECT cis.id AS Id, cis.create_date AS CreateDate, cis.update_date AS UpdateDate,
           cis.delete_date AS DeleteDate, cis.cart_item_id AS CartItemId, cis.store_offering_id AS StoreOfferingId
    FROM [ordering].cart_item_services cis
    INNER JOIN [ordering].cart_items ci ON ci.id = cis.cart_item_id AND ci.delete_date IS NULL
    INNER JOIN [ordering].carts c ON c.id = ci.cart_id
    WHERE c.id = @CartId AND c.customer_id = @CustomerId AND c.status = 'OPEN' AND c.delete_date IS NULL
      AND cis.delete_date IS NULL
    ORDER BY cis.create_date, cis.id;

    SELECT cip.id AS Id, cip.create_date AS CreateDate, cip.update_date AS UpdateDate,
           cip.delete_date AS DeleteDate, cip.cart_item_id AS CartItemId, cip.storage_key AS StorageKey,
           cip.photo_type AS PhotoType
    FROM [ordering].cart_item_photos cip
    INNER JOIN [ordering].cart_items ci ON ci.id = cip.cart_item_id AND ci.delete_date IS NULL
    INNER JOIN [ordering].carts c ON c.id = ci.cart_id
    WHERE c.id = @CartId AND c.customer_id = @CustomerId AND c.status = 'OPEN' AND c.delete_date IS NULL
      AND cip.delete_date IS NULL
    ORDER BY cip.create_date, cip.id;
END;
GO

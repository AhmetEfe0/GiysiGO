SET NOCOUNT ON;
IF @Operation = N'CREATE'
BEGIN
    INSERT catalog.product_categories (id, code, name, is_active)
    VALUES (@CategoryId, @Prefix, N'Liste filtre testi', 1);
    INSERT catalog.product_types (id, category_id, code, name, base_unit, is_active)
    SELECT NEWID(), @CategoryId, CONCAT(@Prefix, N'-', n), CONCAT(N'Liste ürünü ', n), N'PIECE', 1
    FROM (VALUES (1), (2), (3), (4)) numbers(n);
END;
IF @Operation = N'HIDE_INACTIVE'
    UPDATE catalog.product_categories SET is_active = 0, delete_date = NULL WHERE id = @CategoryId;
IF @Operation = N'HIDE_DELETED'
    UPDATE catalog.product_categories SET is_active = 1, delete_date = SYSUTCDATETIME() WHERE id = @CategoryId;
IF @Operation = N'CLEANUP'
BEGIN
    DELETE catalog.product_types WHERE category_id = @CategoryId;
    DELETE catalog.product_categories WHERE id = @CategoryId;
END;

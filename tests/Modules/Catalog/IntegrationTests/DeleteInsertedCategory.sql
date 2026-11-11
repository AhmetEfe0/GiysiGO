UPDATE [catalog].[product_categories]
SET delete_date = SYSUTCDATETIME(), is_active = 0, update_date = SYSUTCDATETIME()
WHERE id = @Id AND delete_date IS NULL;

-- Seed tekrarının sadece eklemeyi değil mevcut veriyi düzeltmeyi de koruduğunu denetler.
UPDATE catalog.product_categories SET name = N'Değişmiş kategori', sort_order = 999,
    is_active = 0, delete_date = SYSUTCDATETIME() WHERE code = N'DAILY';
UPDATE catalog.product_types SET name = N'Değişmiş ürün', base_unit = N'M2',
    is_active = 0, delete_date = SYSUTCDATETIME() WHERE code = N'P001';
UPDATE catalog.services SET name = N'Değişmiş hizmet',
    is_active = 0, delete_date = SYSUTCDATETIME() WHERE code = N'S001';
UPDATE pts SET default_price = 999.99, price_unit = N'M2', selection_kind = N'ALTERNATIVE',
    is_default_selected = 1, is_active = 0, delete_date = SYSUTCDATETIME()
FROM catalog.product_type_services pts
JOIN catalog.product_types p ON p.id = pts.product_type_id
JOIN catalog.services s ON s.id = pts.service_id
WHERE p.code = N'P001' AND s.code = N'S001';

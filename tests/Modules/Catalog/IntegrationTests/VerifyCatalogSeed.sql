SET NOCOUNT ON;

IF (SELECT COUNT(*) FROM catalog.product_categories WHERE code IN (N'DAILY', N'OUTERWEAR', N'OCCASION', N'HOME_TEXTILE', N'ACCESSORIES') AND is_active = 1 AND delete_date IS NULL) <> 5
    THROW 51100, N'Seed beş aktif kaynak kategorisi içermelidir.', 1;
IF (SELECT COUNT(*) FROM catalog.product_types WHERE code LIKE N'P[0-9][0-9][0-9]' AND is_active = 1 AND delete_date IS NULL) <> 48
    THROW 51100, N'Seed 48 aktif kaynak ürünü içermelidir.', 1;
IF (SELECT COUNT(*) FROM catalog.services WHERE code LIKE N'S[0-9][0-9][0-9]' AND is_active = 1 AND delete_date IS NULL) <> 121
    THROW 51100, N'Seed 121 aktif kaynak hizmeti içermelidir.', 1;
IF (SELECT COUNT(*) FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id WHERE pt.code LIKE N'P[0-9][0-9][0-9]' AND pts.is_active = 1 AND pts.delete_date IS NULL) <> 158
    THROW 51100, N'Seed 158 aktif kaynak çifti içermelidir.', 1;
IF EXISTS (SELECT 1 FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id WHERE pt.code LIKE N'P[0-9][0-9][0-9]' AND pts.is_default_selected = 1)
    THROW 51100, N'Hiçbir seed hizmeti başlangıçta seçili olamaz.', 1;
IF EXISTS (SELECT 1 FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id JOIN catalog.services s ON s.id = pts.service_id WHERE pt.code = N'P039' AND s.code = N'S102' AND pts.is_active = 1)
    THROW 51100, N'Kapsam dışı P039/S102 çifti aktif olamaz.', 1;
IF (SELECT COUNT(*) FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id JOIN catalog.services s ON s.id = pts.service_id WHERE ((pt.code = N'P040' AND s.code IN (N'S028', N'S105')) OR (pt.code = N'P041' AND s.code = N'S013')) AND pts.price_unit = N'M2' AND pts.is_active = 1) <> 3
    THROW 51100, N'Perde tadilatları M2 birimi kullanmalıdır.', 1;
IF NOT EXISTS (SELECT 1 FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id JOIN catalog.services s ON s.id = pts.service_id WHERE pt.code = N'P044' AND s.code = N'S112' AND pts.selection_kind = N'ALTERNATIVE' AND pts.is_active = 1)
    THROW 51100, N'Yastık özel yıkaması aktif bir alternatif olmalıdır.', 1;
IF NOT EXISTS (SELECT 1 FROM catalog.product_type_services pts JOIN catalog.product_types pt ON pt.id = pts.product_type_id JOIN catalog.services s ON s.id = pts.service_id WHERE pt.code = N'P037' AND s.code = N'S099' AND pts.selection_kind = N'ADD_ON' AND pts.is_active = 1)
    THROW 51100, N'Büyük boy battaniye farkı aktif bir ek hizmet olmalıdır.', 1;

-- Tekrar çalıştırmalarda kimlik, ilişki, fiyat ve seçim bilgilerinin korunduğunu karşılaştırır.
SELECT snapshot FROM (
    SELECT CONCAT(N'C|', code, N'|', id, N'|', name, N'|', sort_order) AS snapshot
    FROM catalog.product_categories WHERE code IN (N'DAILY', N'OUTERWEAR', N'OCCASION', N'HOME_TEXTILE', N'ACCESSORIES')
    UNION ALL
    SELECT CONCAT(N'P|', code, N'|', id, N'|', category_id, N'|', name, N'|', base_unit)
    FROM catalog.product_types WHERE code LIKE N'P[0-9][0-9][0-9]'
    UNION ALL
    SELECT CONCAT(N'S|', code, N'|', id, N'|', name)
    FROM catalog.services WHERE code LIKE N'S[0-9][0-9][0-9]'
    UNION ALL
    SELECT CONCAT(N'PS|', pt.code, N'/', s.code, N'|', pts.id, N'|', pts.product_type_id, N'|', pts.service_id, N'|', pts.default_price, N'|', pts.currency, N'|', pts.price_unit, N'|', pts.selection_kind, N'|', pts.is_default_selected)
    FROM catalog.product_type_services pts
    JOIN catalog.product_types pt ON pt.id = pts.product_type_id
    JOIN catalog.services s ON s.id = pts.service_id
    WHERE pt.code LIKE N'P[0-9][0-9][0-9]' AND pts.is_active = 1 AND pts.delete_date IS NULL
) snapshots ORDER BY snapshot;

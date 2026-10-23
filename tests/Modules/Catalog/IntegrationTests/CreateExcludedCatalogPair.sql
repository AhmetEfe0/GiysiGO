-- Önceki bir dağıtımda aktif bırakılmış kapsam dışı çifti oluşturur.
IF NOT EXISTS (
    SELECT 1 FROM catalog.product_type_services pts
    JOIN catalog.product_types pt ON pt.id = pts.product_type_id
    JOIN catalog.services s ON s.id = pts.service_id
    WHERE pt.code = N'P039' AND s.code = N'S102'
)
    INSERT catalog.product_type_services
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    SELECT NEWID(), pt.id, s.id, 99, 'TRY', N'PIECE', N'ADD_ON', 0, 1
    FROM catalog.product_types pt CROSS JOIN catalog.services s
    WHERE pt.code = N'P039' AND s.code = N'S102';
ELSE
    UPDATE pts SET is_active = 1
    FROM catalog.product_type_services pts
    JOIN catalog.product_types pt ON pt.id = pts.product_type_id
    JOIN catalog.services s ON s.id = pts.service_id
    WHERE pt.code = N'P039' AND s.code = N'S102';

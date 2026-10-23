-- docs/generate-catalog-seed.mjs tarafından üretilmiştir. Bu dosyayı doğrudan düzenlemeyin.
-- Kimlikler sabit kaynak kodlarından türetilir; kapsam dışı veya karar bekleyen çiftler aktif sunulmaz.
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

-- Kapsam dışı terzi kalemi 2: Ayrı bir mevcut ürün/hizmet çifti yok; P006/S023 zaten 120 TL ile eşlenmiştir.
-- Kapsam dışı terzi kalemi 14: Kullanıcı ağ aşınması/yama onarımını kapsam dışında bıraktı; pantolonda bu işlemin mevcut çifti yok.

IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'DAILY')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'DAILY' AND id <> CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: DAILY.', 1;
    UPDATE [catalog].[product_categories]
    SET name = N'GÜNLÜK GİYİM',
        sort_order = 0,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'DAILY';
END
ELSE
BEGIN
    INSERT [catalog].[product_categories] (id, code, name, sort_order, is_active)
    VALUES (CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'DAILY', N'GÜNLÜK GİYİM', 0, 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'OUTERWEAR')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'OUTERWEAR' AND id <> CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: OUTERWEAR.', 1;
    UPDATE [catalog].[product_categories]
    SET name = N'DIŞ GİYİM',
        sort_order = 1,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'OUTERWEAR';
END
ELSE
BEGIN
    INSERT [catalog].[product_categories] (id, code, name, sort_order, is_active)
    VALUES (CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'OUTERWEAR', N'DIŞ GİYİM', 1, 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'OCCASION')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'OCCASION' AND id <> CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: OCCASION.', 1;
    UPDATE [catalog].[product_categories]
    SET name = N'DAVET & ŞIK GİYİM',
        sort_order = 2,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'OCCASION';
END
ELSE
BEGIN
    INSERT [catalog].[product_categories] (id, code, name, sort_order, is_active)
    VALUES (CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'OCCASION', N'DAVET & ŞIK GİYİM', 2, 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'HOME_TEXTILE')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'HOME_TEXTILE' AND id <> CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: HOME_TEXTILE.', 1;
    UPDATE [catalog].[product_categories]
    SET name = N'EV TEKSTİLİ',
        sort_order = 3,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'HOME_TEXTILE';
END
ELSE
BEGIN
    INSERT [catalog].[product_categories] (id, code, name, sort_order, is_active)
    VALUES (CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'HOME_TEXTILE', N'EV TEKSTİLİ', 3, 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'ACCESSORIES')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_categories] WHERE code = N'ACCESSORIES' AND id <> CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ACCESSORIES.', 1;
    UPDATE [catalog].[product_categories]
    SET name = N'AKSESUAR & DİĞER',
        sort_order = 4,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'ACCESSORIES';
END
ELSE
BEGIN
    INSERT [catalog].[product_categories] (id, code, name, sort_order, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), N'ACCESSORIES', N'AKSESUAR & DİĞER', 4, 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P001')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P001' AND id <> CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P001.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Gömlek', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P001';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P001', N'Gömlek', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P002')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P002' AND id <> CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P002.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Bluz (Kumaş / İpek / Şifon)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P002';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P002', N'Bluz (Kumaş / İpek / Şifon)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P003')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P003' AND id <> CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P003.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Tişört / Polo Yaka', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P003';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P003', N'Tişört / Polo Yaka', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P004')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P004' AND id <> CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P004.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Kazak / Triko / Hırka / Süveter', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P004';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P004', N'Kazak / Triko / Hırka / Süveter', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P005')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P005' AND id <> CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P005.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Sweatshirt / Hoodie', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P005';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P005', N'Sweatshirt / Hoodie', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P006')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P006' AND id <> CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Pantolon (Kumaş / Kot)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P006';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P006', N'Pantolon (Kumaş / Kot)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P007')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P007' AND id <> CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P007.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Etek', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P007';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P007', N'Etek', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P008')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P008' AND id <> CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P008.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Pileli Etek', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P008';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P008', N'Pileli Etek', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P009')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P009' AND id <> CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P009.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Günlük Elbise', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P009';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P009', N'Günlük Elbise', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P010')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P010' AND id <> CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P010.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Tulum / Salopet', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P010';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P010', N'Tulum / Salopet', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P011')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P011' AND id <> CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P011.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), name = N'Şort / Eşofman Altı', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P011';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174'), CONVERT(uniqueidentifier, '77739beb-7693-5fc0-841c-bd5101aa18a3'), N'P011', N'Şort / Eşofman Altı', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P012')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P012' AND id <> CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Ceket / Blazer', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P012';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P012', N'Ceket / Blazer', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P013')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P013' AND id <> CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Kaban / Palto', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P013';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P013', N'Kaban / Palto', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P014')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P014' AND id <> CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P014.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Mont', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P014';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P014', N'Mont', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P015')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P015' AND id <> CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P015.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Kaz / Kuş Tüyü Mont (Kısa)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P015';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P015', N'Kaz / Kuş Tüyü Mont (Kısa)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P016')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P016' AND id <> CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P016.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Kaz / Kuş Tüyü Kaban / Palto (Uzun)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P016';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P016', N'Kaz / Kuş Tüyü Kaban / Palto (Uzun)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P017')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P017' AND id <> CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P017.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Kaz / Kuş Tüyü Yelek / Şişme Yelek', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P017';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P017', N'Kaz / Kuş Tüyü Yelek / Şişme Yelek', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P018')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P018' AND id <> CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P018.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Trençkot / Pardösü', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P018';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P018', N'Trençkot / Pardösü', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P019')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P019' AND id <> CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P019.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Hakiki Deri Ceket / Mont', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P019';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P019', N'Hakiki Deri Ceket / Mont', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P020')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P020' AND id <> CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P020.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Suni Deri Ceket / Mont', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P020';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P020', N'Suni Deri Ceket / Mont', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P021')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P021' AND id <> CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P021.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Süet Ceket / Mont', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P021';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P021', N'Süet Ceket / Mont', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P022')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P022' AND id <> CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P022.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Kürk (Hakiki)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P022';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P022', N'Kürk (Hakiki)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P023')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P023' AND id <> CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P023.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Kürk (Suni)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P023';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P023', N'Kürk (Suni)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P024')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P024' AND id <> CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P024.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), name = N'Motorcu Montu', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P024';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0'), CONVERT(uniqueidentifier, '68cca443-1430-5ff4-8249-061e798b9138'), N'P024', N'Motorcu Montu', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P025')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P025' AND id <> CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P025.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Takım Elbise (2 Parça)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P025';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P025', N'Takım Elbise (2 Parça)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P026')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P026' AND id <> CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P026.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Yelekli Takım Elbise (3 Parça)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P026';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P026', N'Yelekli Takım Elbise (3 Parça)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P027')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P027' AND id <> CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P027.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Abiye / Gece Elbisesi (Sade / Düz)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P027';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P027', N'Abiye / Gece Elbisesi (Sade / Düz)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P028')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P028' AND id <> CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P028.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Abiye / Gece Elbisesi (Taşlı / Pullu / Şifon)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P028';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P028', N'Abiye / Gece Elbisesi (Taşlı / Pullu / Şifon)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P029')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P029' AND id <> CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P029.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Gelinlik (Sade / Düz)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P029';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P029', N'Gelinlik (Sade / Düz)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P030')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P030' AND id <> CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P030.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Gelinlik (İşlemeli / Taşlı / Kuyruklu)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P030';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P030', N'Gelinlik (İşlemeli / Taşlı / Kuyruklu)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P031')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P031' AND id <> CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P031.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Nişanlık / Kınalık / Kaftan', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P031';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P031', N'Nişanlık / Kınalık / Kaftan', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P032')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P032' AND id <> CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P032.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), name = N'Duvak', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P032';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66'), CONVERT(uniqueidentifier, '8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8'), N'P032', N'Duvak', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P033')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P033' AND id <> CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P033.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Elyaf Yorgan (Tek / Çift Kişilik)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P033';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P033', N'Elyaf Yorgan (Tek / Çift Kişilik)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P034')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P034' AND id <> CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P034.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Yün / Pamuk Yorgan', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P034';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P034', N'Yün / Pamuk Yorgan', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P035')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P035' AND id <> CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P035.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Kaz Tüyü Yorgan', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P035';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P035', N'Kaz Tüyü Yorgan', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P036')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P036' AND id <> CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P036.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Battaniye', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P036';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P036', N'Battaniye', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P037')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P037' AND id <> CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P037.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Battaniye (Büyük Boy)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P037';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P037', N'Battaniye (Büyük Boy)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P038')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P038' AND id <> CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P038.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Yatak Örtüsü (Sade)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P038';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P038', N'Yatak Örtüsü (Sade)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P039')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P039' AND id <> CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P039.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Yatak Örtüsü (Boncuklu/Taşlı/Güpürlü)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P039';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P039', N'Yatak Örtüsü (Boncuklu/Taşlı/Güpürlü)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P040')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P040' AND id <> CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P040.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Tül Perde (m2)', base_unit = N'M2',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P040';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P040', N'Tül Perde (m2)', N'M2', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P041')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P041' AND id <> CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P041.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Fon Perde (m2)', base_unit = N'M2',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P041';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P041', N'Fon Perde (m2)', N'M2', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P042')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P042' AND id <> CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P042.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Masa Örtüsü', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P042';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P042', N'Masa Örtüsü', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P043')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P043' AND id <> CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P043.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Koltuk / Kırlent Kılıfı', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P043';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P043', N'Koltuk / Kırlent Kılıfı', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P044')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P044' AND id <> CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P044.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), name = N'Yastık (Elyaf / Tüy)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P044';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e'), CONVERT(uniqueidentifier, '476242ee-b4c5-57ba-bdb7-ff744fff6727'), N'P044', N'Yastık (Elyaf / Tüy)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P045')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P045' AND id <> CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P045.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), name = N'Eşarp / Şal / Fular', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P045';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c'), CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), N'P045', N'Eşarp / Şal / Fular', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P046')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P046' AND id <> CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P046.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), name = N'Kravat / Papyon', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P046';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf'), CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), N'P046', N'Kravat / Papyon', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P047')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P047' AND id <> CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P047.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), name = N'Bez / Kumaş Spor Ayakkabı (Sneaker)', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P047';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1'), CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), N'P047', N'Bez / Kumaş Spor Ayakkabı (Sneaker)', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P048')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = N'P048' AND id <> CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P048.', 1;
    UPDATE [catalog].[product_types]
    SET category_id = CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), name = N'Kasket / Şapka', base_unit = N'PIECE',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'P048';
END
ELSE
BEGIN
    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)
    VALUES (CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17'), CONVERT(uniqueidentifier, 'f8353a9f-0ff7-58a9-8e0a-6bce48da7729'), N'P048', N'Kasket / Şapka', N'PIECE', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S001')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S001' AND id <> CONVERT(uniqueidentifier, '7077bbc5-6f21-525a-abc2-d296fffd0f96'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S001.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Ütü (Standart)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S001';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '7077bbc5-6f21-525a-abc2-d296fffd0f96'), N'S001', N'Kuru Temizleme & Ütü (Standart)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S002')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S002' AND id <> CONVERT(uniqueidentifier, 'd59ffd8d-b69d-503b-8350-83e1f2265ab5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S002.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Ütü (Temizleme Hariç)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S002';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'd59ffd8d-b69d-503b-8350-83e1f2265ab5'), N'S002', N'Sadece Ütü (Temizleme Hariç)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S003')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S003' AND id <> CONVERT(uniqueidentifier, 'eade1c05-2663-50ee-91c2-8f6de0cbb62a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S003.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kol Kısaltma (Manşetli Tadilat)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S003';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'eade1c05-2663-50ee-91c2-8f6de0cbb62a'), N'S003', N'Kol Kısaltma (Manşetli Tadilat)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S004')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S004' AND id <> CONVERT(uniqueidentifier, '45741922-b1f4-51ab-9ad6-021648ce9cde'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S004.', 1;
    UPDATE [catalog].[services]
    SET name = N'Beden Daraltma (Pens)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S004';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '45741922-b1f4-51ab-9ad6-021648ce9cde'), N'S004', N'Beden Daraltma (Pens)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S005')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S005' AND id <> CONVERT(uniqueidentifier, '394cbae8-a2e2-5690-be8f-9ee6b787d7aa'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S005.', 1;
    UPDATE [catalog].[services]
    SET name = N'Düğme Dikimi / Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S005';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '394cbae8-a2e2-5690-be8f-9ee6b787d7aa'), N'S005', N'Düğme Dikimi / Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S006')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S006' AND id <> CONVERT(uniqueidentifier, '445ea14b-4dd2-5d3d-9c57-18e5897af9c4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S006.', 1;
    UPDATE [catalog].[services]
    SET name = N'Hassas Kuru Temizleme & Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S006';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '445ea14b-4dd2-5d3d-9c57-18e5897af9c4'), N'S006', N'Hassas Kuru Temizleme & Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S007')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S007' AND id <> CONVERT(uniqueidentifier, '69517098-d314-5143-9724-cf6ec7c852c9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S007.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Buharlı Form Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S007';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '69517098-d314-5143-9724-cf6ec7c852c9'), N'S007', N'Sadece Buharlı Form Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S008')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S008' AND id <> CONVERT(uniqueidentifier, 'c767508a-27b8-5af3-bb8f-e7851e6b2c20'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S008.', 1;
    UPDATE [catalog].[services]
    SET name = N'Askı / Kol Boyu Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S008';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c767508a-27b8-5af3-bb8f-e7851e6b2c20'), N'S008', N'Askı / Kol Boyu Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S009')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S009' AND id <> CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S009.', 1;
    UPDATE [catalog].[services]
    SET name = N'Beden Daraltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S009';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'), N'S009', N'Beden Daraltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S010')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S010' AND id <> CONVERT(uniqueidentifier, '29dd94b4-5cdb-5454-84ca-549c0d6c2e31'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S010.', 1;
    UPDATE [catalog].[services]
    SET name = N'Dikiş / Sökük Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S010';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '29dd94b4-5cdb-5454-84ca-549c0d6c2e31'), N'S010', N'Dikiş / Sökük Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S011')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S011' AND id <> CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S011.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yıkama & Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S011';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'), N'S011', N'Yıkama & Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S012')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S012' AND id <> CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S012.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S012';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'), N'S012', N'Sadece Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S013')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S013' AND id <> CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S013.', 1;
    UPDATE [catalog].[services]
    SET name = N'Boy Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S013';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4'), N'S013', N'Boy Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S014')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S014' AND id <> CONVERT(uniqueidentifier, 'cd4fe896-319e-5f06-bcc2-1e81de28563a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S014.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yaka / Dikiş Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S014';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'cd4fe896-319e-5f06-bcc2-1e81de28563a'), N'S014', N'Yaka / Dikiş Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S015')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S015' AND id <> CONVERT(uniqueidentifier, 'c564833d-7170-53ce-9d69-5b46db110362'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S015.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yün Kuru Temizleme & Form Pres',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S015';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c564833d-7170-53ce-9d69-5b46db110362'), N'S015', N'Yün Kuru Temizleme & Form Pres', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S016')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S016' AND id <> CONVERT(uniqueidentifier, '0ff86b2c-49e3-56ca-bbca-0c01e24a49dd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S016.', 1;
    UPDATE [catalog].[services]
    SET name = N'Tiftik / Hav Alma Bakımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S016';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0ff86b2c-49e3-56ca-bbca-0c01e24a49dd'), N'S016', N'Tiftik / Hav Alma Bakımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S017')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S017' AND id <> CONVERT(uniqueidentifier, 'da9a789f-fd95-57d1-aba5-2e0759cd92dd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S017.', 1;
    UPDATE [catalog].[services]
    SET name = N'İlmek / Kaçık Örme (Delik Tamiri)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S017';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'da9a789f-fd95-57d1-aba5-2e0759cd92dd'), N'S017', N'İlmek / Kaçık Örme (Delik Tamiri)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S018')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S018' AND id <> CONVERT(uniqueidentifier, '611ba769-e2bf-50db-bc3c-060a0db139c8'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S018.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kol Boyu Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S018';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '611ba769-e2bf-50db-bc3c-060a0db139c8'), N'S018', N'Kol Boyu Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S019')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S019' AND id <> CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S019.', 1;
    UPDATE [catalog].[services]
    SET name = N'Fermuar Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S019';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), N'S019', N'Fermuar Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S020')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S020' AND id <> CONVERT(uniqueidentifier, '21db9ce1-27c3-524b-9af2-4e777105e4e3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S020.', 1;
    UPDATE [catalog].[services]
    SET name = N'Manşet / Cep Dikişi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S020';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '21db9ce1-27c3-524b-9af2-4e777105e4e3'), N'S020', N'Manşet / Cep Dikişi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S021')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S021' AND id <> CONVERT(uniqueidentifier, 'ad7b5cd4-352d-5856-b971-7d7a947b607e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S021.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Çift Çizgi Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S021';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'ad7b5cd4-352d-5856-b971-7d7a947b607e'), N'S021', N'Kuru Temizleme & Çift Çizgi Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S022')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S022' AND id <> CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S022.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S022';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'), N'S022', N'Sadece Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S023')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S023' AND id <> CONVERT(uniqueidentifier, '7c3aa8c9-e1d0-5754-8679-5389db6d82c4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S023.', 1;
    UPDATE [catalog].[services]
    SET name = N'Düz Paça Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S023';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '7c3aa8c9-e1d0-5754-8679-5389db6d82c4'), N'S023', N'Düz Paça Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S024')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S024' AND id <> CONVERT(uniqueidentifier, 'ba164588-634a-5c2c-b594-7c2a5fe848f1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S024.', 1;
    UPDATE [catalog].[services]
    SET name = N'Duble Paça Yapımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S024';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'ba164588-634a-5c2c-b594-7c2a5fe848f1'), N'S024', N'Duble Paça Yapımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S025')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S025' AND id <> CONVERT(uniqueidentifier, '5e76ef7b-fe42-5d22-b0a7-829d1f1e0326'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S025.', 1;
    UPDATE [catalog].[services]
    SET name = N'Bel Daraltma / Genişletme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S025';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '5e76ef7b-fe42-5d22-b0a7-829d1f1e0326'), N'S025', N'Bel Daraltma / Genişletme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S026')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S026' AND id <> CONVERT(uniqueidentifier, '261c8fc7-08a3-5993-bf4a-476b03c870ab'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S026.', 1;
    UPDATE [catalog].[services]
    SET name = N'Basen / Paça Daraltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S026';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '261c8fc7-08a3-5993-bf4a-476b03c870ab'), N'S026', N'Basen / Paça Daraltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S027')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S027' AND id <> CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S027.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S027';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'), N'S027', N'Kuru Temizleme & Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S028')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S028' AND id <> CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S028.', 1;
    UPDATE [catalog].[services]
    SET name = N'Etek Boyu Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S028';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'), N'S028', N'Etek Boyu Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S029')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S029' AND id <> CONVERT(uniqueidentifier, '0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S029.', 1;
    UPDATE [catalog].[services]
    SET name = N'Bel Daraltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S029';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1'), N'S029', N'Bel Daraltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S030')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S030' AND id <> CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S030.', 1;
    UPDATE [catalog].[services]
    SET name = N'Gizli Fermuar Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S030';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'), N'S030', N'Gizli Fermuar Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S031')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S031' AND id <> CONVERT(uniqueidentifier, '2eb0a9e3-1809-5092-8652-9545002af4be'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S031.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Pile Presi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S031';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '2eb0a9e3-1809-5092-8652-9545002af4be'), N'S031', N'Kuru Temizleme & Pile Presi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S032')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S032' AND id <> CONVERT(uniqueidentifier, 'b2984dc4-904c-504a-a51e-0d65997b7069'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S032.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Pile Form Presi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S032';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b2984dc4-904c-504a-a51e-0d65997b7069'), N'S032', N'Sadece Pile Form Presi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S033')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S033' AND id <> CONVERT(uniqueidentifier, '094bbf6a-c8ae-5fc7-80e0-79bd202bb395'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S033.', 1;
    UPDATE [catalog].[services]
    SET name = N'Bel Tadilatı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S033';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '094bbf6a-c8ae-5fc7-80e0-79bd202bb395'), N'S033', N'Bel Tadilatı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S034')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S034' AND id <> CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S034.', 1;
    UPDATE [catalog].[services]
    SET name = N'Paça Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S034';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820'), N'S034', N'Paça Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S035')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S035' AND id <> CONVERT(uniqueidentifier, '699a66f6-56ed-5c05-bdfb-f3bcbf79f00a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S035.', 1;
    UPDATE [catalog].[services]
    SET name = N'Askı / Beden Ayarı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S035';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '699a66f6-56ed-5c05-bdfb-f3bcbf79f00a'), N'S035', N'Askı / Beden Ayarı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S036')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S036' AND id <> CONVERT(uniqueidentifier, '5f4258af-012d-577e-a7ea-c9b3a506dbdc'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S036.', 1;
    UPDATE [catalog].[services]
    SET name = N'Bel Lastiği / Kordon Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S036';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '5f4258af-012d-577e-a7ea-c9b3a506dbdc'), N'S036', N'Bel Lastiği / Kordon Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S037')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S037' AND id <> CONVERT(uniqueidentifier, '563006fb-e70f-51df-b266-64822f63ad02'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S037.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Form Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S037';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '563006fb-e70f-51df-b266-64822f63ad02'), N'S037', N'Kuru Temizleme & Form Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S038')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S038' AND id <> CONVERT(uniqueidentifier, '0b15470c-8116-55e4-bc3a-e407ff91cd7b'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S038.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kol Kısaltma (Düz)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S038';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0b15470c-8116-55e4-bc3a-e407ff91cd7b'), N'S038', N'Kol Kısaltma (Düz)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S039')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S039' AND id <> CONVERT(uniqueidentifier, '59590b50-617b-55e2-86bf-01abf06e0a87'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S039.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kol Kısaltma (Düğmeli)',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S039';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '59590b50-617b-55e2-86bf-01abf06e0a87'), N'S039', N'Kol Kısaltma (Düğmeli)', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S040')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S040' AND id <> CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S040.', 1;
    UPDATE [catalog].[services]
    SET name = N'Astar Söküğü Tamiri',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S040';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c'), N'S040', N'Astar Söküğü Tamiri', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S041')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S041' AND id <> CONVERT(uniqueidentifier, '41d37138-5011-5fbf-8fe9-0f45ec14cf2f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S041.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Form Pres',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S041';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '41d37138-5011-5fbf-8fe9-0f45ec14cf2f'), N'S041', N'Kuru Temizleme & Form Pres', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S042')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S042' AND id <> CONVERT(uniqueidentifier, 'b1f37ddc-c005-5556-a0c5-ac806978f0bc'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S042.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Form Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S042';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b1f37ddc-c005-5556-a0c5-ac806978f0bc'), N'S042', N'Sadece Form Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S043')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S043' AND id <> CONVERT(uniqueidentifier, '0e695b64-2889-5fe3-b6a4-aa680d63363b'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S043.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kol Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S043';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0e695b64-2889-5fe3-b6a4-aa680d63363b'), N'S043', N'Kol Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S044')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S044' AND id <> CONVERT(uniqueidentifier, '8e73dff7-96f2-5030-901c-ec53f30e2ae2'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S044.', 1;
    UPDATE [catalog].[services]
    SET name = N'Astar Değişimi / Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S044';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '8e73dff7-96f2-5030-901c-ec53f30e2ae2'), N'S044', N'Astar Değişimi / Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S045')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S045' AND id <> CONVERT(uniqueidentifier, '8c0c364f-7732-5cde-97cd-4c69fefd032d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S045.', 1;
    UPDATE [catalog].[services]
    SET name = N'Düğme / Çıtçıt Dikimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S045';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '8c0c364f-7732-5cde-97cd-4c69fefd032d'), N'S045', N'Düğme / Çıtçıt Dikimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S046')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S046' AND id <> CONVERT(uniqueidentifier, '66c63af4-1a42-5ac4-aa2b-05c210686f8d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S046.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kemik Fermuar Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S046';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '66c63af4-1a42-5ac4-aa2b-05c210686f8d'), N'S046', N'Kemik Fermuar Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S047')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S047' AND id <> CONVERT(uniqueidentifier, 'c070a9c1-cce2-519a-9e15-441e5210c83d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S047.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yırtık / Kumaş Yaması',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S047';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c070a9c1-cce2-519a-9e15-441e5210c83d'), N'S047', N'Yırtık / Kumaş Yaması', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S048')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S048' AND id <> CONVERT(uniqueidentifier, '609afdd2-772e-5541-bc6c-96be9f041aae'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S048.', 1;
    UPDATE [catalog].[services]
    SET name = N'Özel Kuru Temizleme & Tüy Kabartma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S048';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '609afdd2-772e-5541-bc6c-96be9f041aae'), N'S048', N'Özel Kuru Temizleme & Tüy Kabartma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S049')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S049' AND id <> CONVERT(uniqueidentifier, '6650cb67-716b-549e-ac5a-bd7897c7513f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S049.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yırtık / Dikiş Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S049';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '6650cb67-716b-549e-ac5a-bd7897c7513f'), N'S049', N'Yırtık / Dikiş Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S050')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S050' AND id <> CONVERT(uniqueidentifier, '9c397969-7be5-5df2-a4e0-48039b8c24aa'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S050.', 1;
    UPDATE [catalog].[services]
    SET name = N'Uzun Temizleme & Tüy Kabartma Presi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S050';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '9c397969-7be5-5df2-a4e0-48039b8c24aa'), N'S050', N'Uzun Temizleme & Tüy Kabartma Presi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S051')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S051' AND id <> CONVERT(uniqueidentifier, '1424f776-c630-5a22-9a85-e6987d2ffc0c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S051.', 1;
    UPDATE [catalog].[services]
    SET name = N'Çift Yönlü Uzun Fermuar Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S051';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '1424f776-c630-5a22-9a85-e6987d2ffc0c'), N'S051', N'Çift Yönlü Uzun Fermuar Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S052')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S052' AND id <> CONVERT(uniqueidentifier, '05aeb3f9-f2f6-56e7-9292-e4e26bce0715'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S052.', 1;
    UPDATE [catalog].[services]
    SET name = N'Temizleme & Kabartma Bakımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S052';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '05aeb3f9-f2f6-56e7-9292-e4e26bce0715'), N'S052', N'Temizleme & Kabartma Bakımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S053')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S053' AND id <> CONVERT(uniqueidentifier, '176e4cf8-e704-596b-aa28-018b698dc755'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S053.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Form Ütüsü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S053';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '176e4cf8-e704-596b-aa28-018b698dc755'), N'S053', N'Kuru Temizleme & Form Ütüsü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S054')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S054' AND id <> CONVERT(uniqueidentifier, '4ad2db46-3f0b-5d90-ae82-93ff1fb94172'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S054.', 1;
    UPDATE [catalog].[services]
    SET name = N'Su İtici Koruyucu Bakım',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S054';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '4ad2db46-3f0b-5d90-ae82-93ff1fb94172'), N'S054', N'Su İtici Koruyucu Bakım', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S055')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S055' AND id <> CONVERT(uniqueidentifier, '1219e2ed-0953-5ef7-864c-4a9899337f46'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S055.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kol / Boy Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S055';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '1219e2ed-0953-5ef7-864c-4a9899337f46'), N'S055', N'Kol / Boy Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S056')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S056' AND id <> CONVERT(uniqueidentifier, '3ad4f605-fe02-5bd0-b07f-e9f774dafc0a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S056.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kemer / Toka Tamiri',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S056';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '3ad4f605-fe02-5bd0-b07f-e9f774dafc0a'), N'S056', N'Kemer / Toka Tamiri', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S057')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S057' AND id <> CONVERT(uniqueidentifier, '2e77d708-5fa6-54d1-bc4e-3bafbc0546bf'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S057.', 1;
    UPDATE [catalog].[services]
    SET name = N'Özel Deri Temizleme & Besleme Yağlaması',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S057';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '2e77d708-5fa6-54d1-bc4e-3bafbc0546bf'), N'S057', N'Özel Deri Temizleme & Besleme Yağlaması', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S058')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S058' AND id <> CONVERT(uniqueidentifier, '6418be14-d7d7-5f1d-8529-05290fc827ce'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S058.', 1;
    UPDATE [catalog].[services]
    SET name = N'Deri Boyama & Renk Yenileme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S058';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '6418be14-d7d7-5f1d-8529-05290fc827ce'), N'S058', N'Deri Boyama & Renk Yenileme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S059')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S059' AND id <> CONVERT(uniqueidentifier, '30fa771e-8552-5625-81b0-77204a320daa'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S059.', 1;
    UPDATE [catalog].[services]
    SET name = N'Deri Fermuar Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S059';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '30fa771e-8552-5625-81b0-77204a320daa'), N'S059', N'Deri Fermuar Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S060')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S060' AND id <> CONVERT(uniqueidentifier, '0fdcfbe7-1292-590c-aa48-0ad68e140f72'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S060.', 1;
    UPDATE [catalog].[services]
    SET name = N'Deri Kol Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S060';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0fdcfbe7-1292-590c-aa48-0ad68e140f72'), N'S060', N'Deri Kol Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S061')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S061' AND id <> CONVERT(uniqueidentifier, '8f54536c-31b1-51c7-acdd-810dc8d9e32a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S061.', 1;
    UPDATE [catalog].[services]
    SET name = N'Hassas Nemli Temizleme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S061';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '8f54536c-31b1-51c7-acdd-810dc8d9e32a'), N'S061', N'Hassas Nemli Temizleme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S062')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S062' AND id <> CONVERT(uniqueidentifier, '8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S062.', 1;
    UPDATE [catalog].[services]
    SET name = N'Süet Temizleme & Doku Canlandırma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S062';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8'), N'S062', N'Süet Temizleme & Doku Canlandırma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S063')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S063' AND id <> CONVERT(uniqueidentifier, 'f8c3584c-7f2c-5d69-98eb-35866aac0b1a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S063.', 1;
    UPDATE [catalog].[services]
    SET name = N'Fermuar / Düğme Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S063';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f8c3584c-7f2c-5d69-98eb-35866aac0b1a'), N'S063', N'Fermuar / Düğme Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S064')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S064' AND id <> CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S064.', 1;
    UPDATE [catalog].[services]
    SET name = N'Hassas Kürk Temizleme & Havlandırma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S064';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1'), N'S064', N'Hassas Kürk Temizleme & Havlandırma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S065')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S065' AND id <> CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S065.', 1;
    UPDATE [catalog].[services]
    SET name = N'Klips / Kopça Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S065';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb'), N'S065', N'Klips / Kopça Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S066')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S066' AND id <> CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S066.', 1;
    UPDATE [catalog].[services]
    SET name = N'Astar Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S066';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee'), N'S066', N'Astar Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S067')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S067' AND id <> CONVERT(uniqueidentifier, 'ed75dc26-1195-575d-9449-a9f24130bed4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S067.', 1;
    UPDATE [catalog].[services]
    SET name = N'Koruma Sökümlü Derin Temizleme & Dezenfeksiyon',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S067';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'ed75dc26-1195-575d-9449-a9f24130bed4'), N'S067', N'Koruma Sökümlü Derin Temizleme & Dezenfeksiyon', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S068')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S068' AND id <> CONVERT(uniqueidentifier, 'e495909b-79af-5e80-a006-84d850bda911'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S068.', 1;
    UPDATE [catalog].[services]
    SET name = N'Ağır Hizmet Fermuar Değişimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S068';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'e495909b-79af-5e80-a006-84d850bda911'), N'S068', N'Ağır Hizmet Fermuar Değişimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S069')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S069' AND id <> CONVERT(uniqueidentifier, '81732f9b-beec-540e-aafe-4bd8a8d63119'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S069.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Çift Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S069';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '81732f9b-beec-540e-aafe-4bd8a8d63119'), N'S069', N'Kuru Temizleme & Çift Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S070')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S070' AND id <> CONVERT(uniqueidentifier, 'f067cbfb-660a-5f13-b80e-64ec0997ecfe'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S070.', 1;
    UPDATE [catalog].[services]
    SET name = N'Pantolon Paça Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S070';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f067cbfb-660a-5f13-b80e-64ec0997ecfe'), N'S070', N'Pantolon Paça Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S071')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S071' AND id <> CONVERT(uniqueidentifier, '9d88b3d2-f617-54a0-9c4d-740f4c3ed946'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S071.', 1;
    UPDATE [catalog].[services]
    SET name = N'Pantolon Bel Daraltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S071';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '9d88b3d2-f617-54a0-9c4d-740f4c3ed946'), N'S071', N'Pantolon Bel Daraltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S072')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S072' AND id <> CONVERT(uniqueidentifier, 'a04acb35-29d5-5bfd-96a6-c501670049f2'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S072.', 1;
    UPDATE [catalog].[services]
    SET name = N'Ceket Kol Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S072';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'a04acb35-29d5-5bfd-96a6-c501670049f2'), N'S072', N'Ceket Kol Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S073')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S073' AND id <> CONVERT(uniqueidentifier, '35d552ba-dccb-54a4-b722-5ad9b91495e1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S073.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Komple Pres',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S073';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '35d552ba-dccb-54a4-b722-5ad9b91495e1'), N'S073', N'Kuru Temizleme & Komple Pres', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S074')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S074' AND id <> CONVERT(uniqueidentifier, 'f6060f16-0ff7-5cd5-879b-01e4f22b3f28'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S074.', 1;
    UPDATE [catalog].[services]
    SET name = N'Komple Beden Ölçü Provası',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S074';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f6060f16-0ff7-5cd5-879b-01e4f22b3f28'), N'S074', N'Komple Beden Ölçü Provası', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S075')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S075' AND id <> CONVERT(uniqueidentifier, '1ee68bf0-8fc4-5769-9278-178b31f83abf'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S075.', 1;
    UPDATE [catalog].[services]
    SET name = N'Hassas Kuru Temizleme & Buhar Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S075';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '1ee68bf0-8fc4-5769-9278-178b31f83abf'), N'S075', N'Hassas Kuru Temizleme & Buhar Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S076')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S076' AND id <> CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S076.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Askı Buhar Ütüsü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S076';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'), N'S076', N'Sadece Askı Buhar Ütüsü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S077')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S077' AND id <> CONVERT(uniqueidentifier, '9e6cb8ea-367a-5df5-a378-56981029751a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S077.', 1;
    UPDATE [catalog].[services]
    SET name = N'Beden / Göğüs Daraltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S077';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '9e6cb8ea-367a-5df5-a378-56981029751a'), N'S077', N'Beden / Göğüs Daraltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S078')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S078' AND id <> CONVERT(uniqueidentifier, 'd829249a-8913-5eb7-8784-f08b4dfb3214'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S078.', 1;
    UPDATE [catalog].[services]
    SET name = N'Askı Boyu Ayarlama',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S078';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'd829249a-8913-5eb7-8784-f08b4dfb3214'), N'S078', N'Askı Boyu Ayarlama', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S079')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S079' AND id <> CONVERT(uniqueidentifier, '37f584ca-3203-5713-81c4-6d0c81e00c3e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S079.', 1;
    UPDATE [catalog].[services]
    SET name = N'Korumalı Hassas Temizleme & Buhar',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S079';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '37f584ca-3203-5713-81c4-6d0c81e00c3e'), N'S079', N'Korumalı Hassas Temizleme & Buhar', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S080')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S080' AND id <> CONVERT(uniqueidentifier, '7742e586-122d-5cd4-b414-196fc5c3f513'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S080.', 1;
    UPDATE [catalog].[services]
    SET name = N'Katmanlı Tül Boy Kısaltma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S080';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '7742e586-122d-5cd4-b414-196fc5c3f513'), N'S080', N'Katmanlı Tül Boy Kısaltma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S081')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S081' AND id <> CONVERT(uniqueidentifier, 'fa93fb50-bd3c-5cba-8690-7a2cb5161c68'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S081.', 1;
    UPDATE [catalog].[services]
    SET name = N'Düşen Taş / Pul Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S081';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'fa93fb50-bd3c-5cba-8690-7a2cb5161c68'), N'S081', N'Düşen Taş / Pul Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S082')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S082' AND id <> CONVERT(uniqueidentifier, '5cd4a254-ddb8-5897-bbb1-6a4eee015437'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S082.', 1;
    UPDATE [catalog].[services]
    SET name = N'Detaylı Temizleme & Buhar Pres',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S082';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '5cd4a254-ddb8-5897-bbb1-6a4eee015437'), N'S082', N'Detaylı Temizleme & Buhar Pres', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S083')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S083' AND id <> CONVERT(uniqueidentifier, '6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S083.', 1;
    UPDATE [catalog].[services]
    SET name = N'Boy Kısaltma / Beden Ayarı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S083';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671'), N'S083', N'Boy Kısaltma / Beden Ayarı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S084')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S084' AND id <> CONVERT(uniqueidentifier, 'cf76c324-dc08-581a-a9c6-7c72de3be743'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S084.', 1;
    UPDATE [catalog].[services]
    SET name = N'Özel Havuz Leke Temizliği & Askı Presi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S084';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'cf76c324-dc08-581a-a9c6-7c72de3be743'), N'S084', N'Özel Havuz Leke Temizliği & Askı Presi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S085')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S085' AND id <> CONVERT(uniqueidentifier, 'e802bbab-75a6-5df3-aa8b-6e905bee20c6'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S085.', 1;
    UPDATE [catalog].[services]
    SET name = N'Tül Yırtığı Tamiri',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S085';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'e802bbab-75a6-5df3-aa8b-6e905bee20c6'), N'S085', N'Tül Yırtığı Tamiri', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S086')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S086' AND id <> CONVERT(uniqueidentifier, 'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S086.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuyruk / Korse Tadilatı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S086';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a'), N'S086', N'Kuyruk / Korse Tadilatı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S087')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S087' AND id <> CONVERT(uniqueidentifier, '1e2e5bab-8745-5351-8652-601e4fe2d4a2'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S087.', 1;
    UPDATE [catalog].[services]
    SET name = N'Hassas İşlemeli Kumaş Temizleme & Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S087';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '1e2e5bab-8745-5351-8652-601e4fe2d4a2'), N'S087', N'Hassas İşlemeli Kumaş Temizleme & Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S088')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S088' AND id <> CONVERT(uniqueidentifier, 'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S088.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sırma / Pul / Sim Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S088';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70'), N'S088', N'Sırma / Pul / Sim Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S089')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S089' AND id <> CONVERT(uniqueidentifier, '0dea4e35-e64a-5b4e-bde7-23e73d7d3262'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S089.', 1;
    UPDATE [catalog].[services]
    SET name = N'Hassas Temizleme & Buhar',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S089';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0dea4e35-e64a-5b4e-bde7-23e73d7d3262'), N'S089', N'Hassas Temizleme & Buhar', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S090')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S090' AND id <> CONVERT(uniqueidentifier, 'c3a49d43-a07c-5ccd-850e-d110a225d2ab'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S090.', 1;
    UPDATE [catalog].[services]
    SET name = N'Toka / Tarak Sabitleme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S090';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'c3a49d43-a07c-5ccd-850e-d110a225d2ab'), N'S090', N'Toka / Tarak Sabitleme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S091')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S091' AND id <> CONVERT(uniqueidentifier, '9d0b6c0b-2fd0-5260-91b8-4881aa43c390'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S091.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sanayi Tipi Hijyenik Yıkama & Kurutma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S091';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '9d0b6c0b-2fd0-5260-91b8-4881aa43c390'), N'S091', N'Sanayi Tipi Hijyenik Yıkama & Kurutma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S092')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S092' AND id <> CONVERT(uniqueidentifier, 'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S092.', 1;
    UPDATE [catalog].[services]
    SET name = N'Büyük Boy / Battal Ebat Farkı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S092';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a'), N'S092', N'Büyük Boy / Battal Ebat Farkı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S093')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S093' AND id <> CONVERT(uniqueidentifier, '9098892b-5348-5fa5-9969-e5fb8913fe3f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S093.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yırtık / Sökük Dikişi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S093';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '9098892b-5348-5fa5-9969-e5fb8913fe3f'), N'S093', N'Yırtık / Sökük Dikişi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S094')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S094' AND id <> CONVERT(uniqueidentifier, '0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S094.', 1;
    UPDATE [catalog].[services]
    SET name = N'Özel Dolgu Koruma Yıkama & Hav Kurutma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S094';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2'), N'S094', N'Özel Dolgu Koruma Yıkama & Hav Kurutma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S095')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S095' AND id <> CONVERT(uniqueidentifier, '71db8c41-d5a2-5df5-ab2d-444cb07bd73f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S095.', 1;
    UPDATE [catalog].[services]
    SET name = N'Çift Kişilik Ebat Farkı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S095';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '71db8c41-d5a2-5df5-ab2d-444cb07bd73f'), N'S095', N'Çift Kişilik Ebat Farkı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S096')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S096' AND id <> CONVERT(uniqueidentifier, '96ce5b05-8c8d-5b10-b817-3e625456f458'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S096.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kenar Dikiş Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S096';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '96ce5b05-8c8d-5b10-b817-3e625456f458'), N'S096', N'Kenar Dikiş Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S097')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S097' AND id <> CONVERT(uniqueidentifier, '0e691bb2-79b5-5385-9d67-14d4ba810e8f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S097.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kaz Tüyü Açıcı Yıkama & Kabartma Kurutması',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S097';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0e691bb2-79b5-5385-9d67-14d4ba810e8f'), N'S097', N'Kaz Tüyü Açıcı Yıkama & Kabartma Kurutması', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S098')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S098' AND id <> CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S098.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yumuşatıcı Yıkama & Kurutma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S098';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29'), N'S098', N'Yumuşatıcı Yıkama & Kurutma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S099')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S099' AND id <> CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S099.', 1;
    UPDATE [catalog].[services]
    SET name = N'Büyük Boy / Pelüş Farkı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S099';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71'), N'S099', N'Büyük Boy / Pelüş Farkı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S100')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S100' AND id <> CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S100.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kenar Overlok Dikişi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S100';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac'), N'S100', N'Kenar Overlok Dikişi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S101')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S101' AND id <> CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S101.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yıkama & Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S101';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587'), N'S101', N'Yıkama & Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S102')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S102' AND id <> CONVERT(uniqueidentifier, 'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S102.', 1;
    UPDATE [catalog].[services]
    SET name = N'Taşlı / Güpürlü Hassas İşlem Farkı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S102';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae'), N'S102', N'Taşlı / Güpürlü Hassas İşlem Farkı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S103')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S103' AND id <> CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S103.', 1;
    UPDATE [catalog].[services]
    SET name = N'Saçak / Dikiş Tamiri',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S103';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814'), N'S103', N'Saçak / Dikiş Tamiri', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S104')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S104' AND id <> CONVERT(uniqueidentifier, 'bb26b219-d0dd-5c5f-8882-432803cc5ed6'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S104.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yıkama & Buharlı Kırışıklık Açma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S104';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'bb26b219-d0dd-5c5f-8882-432803cc5ed6'), N'S104', N'Yıkama & Buharlı Kırışıklık Açma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S105')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S105' AND id <> CONVERT(uniqueidentifier, '3ad1db91-07bf-5ca0-b200-962c7d895da5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S105.', 1;
    UPDATE [catalog].[services]
    SET name = N'Rulet / Ekstrafor Dikimi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S105';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '3ad1db91-07bf-5ca0-b200-962c7d895da5'), N'S105', N'Rulet / Ekstrafor Dikimi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S106')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S106' AND id <> CONVERT(uniqueidentifier, '59233147-975b-57f3-9f55-40bc4fe0ea45'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S106.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Form Presi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S106';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '59233147-975b-57f3-9f55-40bc4fe0ea45'), N'S106', N'Kuru Temizleme & Form Presi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S107')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S107' AND id <> CONVERT(uniqueidentifier, '55488406-f554-5b15-a97d-938298d3d089'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S107.', 1;
    UPDATE [catalog].[services]
    SET name = N'Leke Çıkarma Banyosu & Kolalı Pres',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S107';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '55488406-f554-5b15-a97d-938298d3d089'), N'S107', N'Leke Çıkarma Banyosu & Kolalı Pres', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S108')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S108' AND id <> CONVERT(uniqueidentifier, '648a9052-8cc6-53f6-99fd-86f778214537'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S108.', 1;
    UPDATE [catalog].[services]
    SET name = N'Sadece Kolalı Pres Ütü',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S108';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '648a9052-8cc6-53f6-99fd-86f778214537'), N'S108', N'Sadece Kolalı Pres Ütü', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S109')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S109' AND id <> CONVERT(uniqueidentifier, 'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S109.', 1;
    UPDATE [catalog].[services]
    SET name = N'Köşe Dikiş Tamiri',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S109';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee'), N'S109', N'Köşe Dikiş Tamiri', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S110')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S110' AND id <> CONVERT(uniqueidentifier, 'b562c556-aa7f-5b33-bf0a-44cc105b22e7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S110.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S110';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'b562c556-aa7f-5b33-bf0a-44cc105b22e7'), N'S110', N'Kuru Temizleme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S111')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S111' AND id <> CONVERT(uniqueidentifier, 'de213140-b4b5-5c00-8c74-bcdafa9bd2a7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S111.', 1;
    UPDATE [catalog].[services]
    SET name = N'Elyaf Yıkama & Dezenfeksiyon',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S111';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'de213140-b4b5-5c00-8c74-bcdafa9bd2a7'), N'S111', N'Elyaf Yıkama & Dezenfeksiyon', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S112')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S112' AND id <> CONVERT(uniqueidentifier, 'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S112.', 1;
    UPDATE [catalog].[services]
    SET name = N'Yün / Kaz Tüyü Özel Yıkama',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S112';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4'), N'S112', N'Yün / Kaz Tüyü Özel Yıkama', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S113')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S113' AND id <> CONVERT(uniqueidentifier, '0bb1b195-0c64-5f7c-997d-63290a0dada5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S113.', 1;
    UPDATE [catalog].[services]
    SET name = N'İpek Kuru Temizleme & Buhar',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S113';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '0bb1b195-0c64-5f7c-997d-63290a0dada5'), N'S113', N'İpek Kuru Temizleme & Buhar', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S114')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S114' AND id <> CONVERT(uniqueidentifier, 'bacfff04-af69-5bcd-ad84-f5c54a00d82b'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S114.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kenar Dikişi',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S114';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'bacfff04-af69-5bcd-ad84-f5c54a00d82b'), N'S114', N'Kenar Dikişi', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S115')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S115' AND id <> CONVERT(uniqueidentifier, '9cc533b2-48be-53e7-b6c9-ab21bdb2fd56'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S115.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kuru Temizleme & Pres',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S115';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '9cc533b2-48be-53e7-b6c9-ab21bdb2fd56'), N'S115', N'Kuru Temizleme & Pres', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S116')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S116' AND id <> CONVERT(uniqueidentifier, '558de248-1ed3-5efe-8299-626498657fe9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S116.', 1;
    UPDATE [catalog].[services]
    SET name = N'Arka Dikiş Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S116';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '558de248-1ed3-5efe-8299-626498657fe9'), N'S116', N'Arka Dikiş Onarımı', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S117')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S117' AND id <> CONVERT(uniqueidentifier, '70d9a8e5-fd50-55e9-8186-4bc411a2b163'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S117.', 1;
    UPDATE [catalog].[services]
    SET name = N'Manuel Köpüklü Yıkama & Ozon',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S117';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '70d9a8e5-fd50-55e9-8186-4bc411a2b163'), N'S117', N'Manuel Köpüklü Yıkama & Ozon', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S118')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S118' AND id <> CONVERT(uniqueidentifier, '66897085-9f8f-5599-8a1e-3c72e7b92f73'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S118.', 1;
    UPDATE [catalog].[services]
    SET name = N'Taban Yapıştırma',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S118';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '66897085-9f8f-5599-8a1e-3c72e7b92f73'), N'S118', N'Taban Yapıştırma', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S119')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S119' AND id <> CONVERT(uniqueidentifier, '63a1ffa2-6167-5ce9-94f4-6ff191af8431'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S119.', 1;
    UPDATE [catalog].[services]
    SET name = N'Bağcık Yenileme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S119';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '63a1ffa2-6167-5ce9-94f4-6ff191af8431'), N'S119', N'Bağcık Yenileme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S120')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S120' AND id <> CONVERT(uniqueidentifier, '2b823fe4-9cbf-543d-a0b1-8bc51b9db922'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S120.', 1;
    UPDATE [catalog].[services]
    SET name = N'Kalıp Form Kuru Temizleme',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S120';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, '2b823fe4-9cbf-543d-a0b1-8bc51b9db922'), N'S120', N'Kalıp Form Kuru Temizleme', 1);
END;

IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S121')
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[services] WHERE code = N'S121' AND id <> CONVERT(uniqueidentifier, 'f7134bc3-cf91-5bac-872c-fe3285278016'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: S121.', 1;
    UPDATE [catalog].[services]
    SET name = N'İç Bant / Dikiş Onarımı',
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE code = N'S121';
END
ELSE
BEGIN
    INSERT [catalog].[services] (id, code, name, is_active)
    VALUES (CONVERT(uniqueidentifier, 'f7134bc3-cf91-5bac-872c-fe3285278016'), N'S121', N'İç Bant / Dikiş Onarımı', 1);
END;

-- Seed çifti P001/S001 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '7077bbc5-6f21-525a-abc2-d296fffd0f96'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '7077bbc5-6f21-525a-abc2-d296fffd0f96') AND id <> CONVERT(uniqueidentifier, '87da03a6-d4c5-5c59-9908-7b1b5daa2d56'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P001/S001.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '7077bbc5-6f21-525a-abc2-d296fffd0f96');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '87da03a6-d4c5-5c59-9908-7b1b5daa2d56'), CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'), CONVERT(uniqueidentifier, '7077bbc5-6f21-525a-abc2-d296fffd0f96'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P001/S002 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, 'd59ffd8d-b69d-503b-8350-83e1f2265ab5'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, 'd59ffd8d-b69d-503b-8350-83e1f2265ab5') AND id <> CONVERT(uniqueidentifier, 'e1194455-1b0d-5fa2-aaae-265ee0190caa'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P001/S002.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, 'd59ffd8d-b69d-503b-8350-83e1f2265ab5');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e1194455-1b0d-5fa2-aaae-265ee0190caa'), CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'), CONVERT(uniqueidentifier, 'd59ffd8d-b69d-503b-8350-83e1f2265ab5'), 100.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P001/S003 (PIECE, ADD_ON; terzi kalemi 10)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, 'eade1c05-2663-50ee-91c2-8f6de0cbb62a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, 'eade1c05-2663-50ee-91c2-8f6de0cbb62a') AND id <> CONVERT(uniqueidentifier, '7f4a2fcc-a66a-55f9-a6d6-5caf3b0a5708'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P001/S003.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, 'eade1c05-2663-50ee-91c2-8f6de0cbb62a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '7f4a2fcc-a66a-55f9-a6d6-5caf3b0a5708'), CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'), CONVERT(uniqueidentifier, 'eade1c05-2663-50ee-91c2-8f6de0cbb62a'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P001/S004 (PIECE, ADD_ON; terzi kalemi 12)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '45741922-b1f4-51ab-9ad6-021648ce9cde'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '45741922-b1f4-51ab-9ad6-021648ce9cde') AND id <> CONVERT(uniqueidentifier, 'f6f83602-eb0d-55c7-9535-f35646848761'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P001/S004.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '45741922-b1f4-51ab-9ad6-021648ce9cde');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'f6f83602-eb0d-55c7-9535-f35646848761'), CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'), CONVERT(uniqueidentifier, '45741922-b1f4-51ab-9ad6-021648ce9cde'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P001/S005 (PIECE, ADD_ON; terzi kalemi 16)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '394cbae8-a2e2-5690-be8f-9ee6b787d7aa'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '394cbae8-a2e2-5690-be8f-9ee6b787d7aa') AND id <> CONVERT(uniqueidentifier, 'e14b5be3-f7d6-5d0c-97fc-eccad1a44d54'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P001/S005.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 30.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7') AND service_id = CONVERT(uniqueidentifier, '394cbae8-a2e2-5690-be8f-9ee6b787d7aa');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e14b5be3-f7d6-5d0c-97fc-eccad1a44d54'), CONVERT(uniqueidentifier, '900fc4b2-7ee8-51b3-83e5-b804fd6b24f7'), CONVERT(uniqueidentifier, '394cbae8-a2e2-5690-be8f-9ee6b787d7aa'), 30.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P002/S006 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '445ea14b-4dd2-5d3d-9c57-18e5897af9c4'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '445ea14b-4dd2-5d3d-9c57-18e5897af9c4') AND id <> CONVERT(uniqueidentifier, 'a8e95908-286d-5282-8450-20d8a197d063'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P002/S006.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '445ea14b-4dd2-5d3d-9c57-18e5897af9c4');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'a8e95908-286d-5282-8450-20d8a197d063'), CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'), CONVERT(uniqueidentifier, '445ea14b-4dd2-5d3d-9c57-18e5897af9c4'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P002/S007 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '69517098-d314-5143-9724-cf6ec7c852c9'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '69517098-d314-5143-9724-cf6ec7c852c9') AND id <> CONVERT(uniqueidentifier, 'e3930efe-aae6-53f1-aeab-c893d59f0fd4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P002/S007.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '69517098-d314-5143-9724-cf6ec7c852c9');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e3930efe-aae6-53f1-aeab-c893d59f0fd4'), CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'), CONVERT(uniqueidentifier, '69517098-d314-5143-9724-cf6ec7c852c9'), 80.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P002/S008 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, 'c767508a-27b8-5af3-bb8f-e7851e6b2c20'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, 'c767508a-27b8-5af3-bb8f-e7851e6b2c20') AND id <> CONVERT(uniqueidentifier, '0675027a-15bc-56fa-8cfa-0c40cd745a67'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P002/S008.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 130.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, 'c767508a-27b8-5af3-bb8f-e7851e6b2c20');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0675027a-15bc-56fa-8cfa-0c40cd745a67'), CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'), CONVERT(uniqueidentifier, 'c767508a-27b8-5af3-bb8f-e7851e6b2c20'), 130.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P002/S009 (PIECE, ADD_ON; terzi kalemi 12)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328') AND id <> CONVERT(uniqueidentifier, '525c04dc-4101-51b2-a537-16f05d26124e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P002/S009.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 140.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '525c04dc-4101-51b2-a537-16f05d26124e'), CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'), CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'), 140.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P002/S010 (PIECE, ADD_ON; terzi kalemi 15)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '29dd94b4-5cdb-5454-84ca-549c0d6c2e31'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '29dd94b4-5cdb-5454-84ca-549c0d6c2e31') AND id <> CONVERT(uniqueidentifier, 'dd297916-808a-5fdc-a8d9-9cba76cd87b1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P002/S010.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 70.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d') AND service_id = CONVERT(uniqueidentifier, '29dd94b4-5cdb-5454-84ca-549c0d6c2e31');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'dd297916-808a-5fdc-a8d9-9cba76cd87b1'), CONVERT(uniqueidentifier, 'c30dfa10-5873-56b9-b906-d2b95df57d8d'), CONVERT(uniqueidentifier, '29dd94b4-5cdb-5454-84ca-549c0d6c2e31'), 70.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P003/S011 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65') AND id <> CONVERT(uniqueidentifier, '29ff18f4-262a-5f97-843d-c9ad3479903e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P003/S011.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '29ff18f4-262a-5f97-843d-c9ad3479903e'), CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe'), CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P003/S012 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053') AND id <> CONVERT(uniqueidentifier, '04d7ca6e-fd78-5bbf-a752-e08d4520888f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P003/S012.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '04d7ca6e-fd78-5bbf-a752-e08d4520888f'), CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe'), CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'), 80.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P003/S013 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4') AND id <> CONVERT(uniqueidentifier, 'd9ce33b7-77d4-56a9-a09e-5e8c13b2c41f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P003/S013.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd9ce33b7-77d4-56a9-a09e-5e8c13b2c41f'), CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe'), CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P003/S014 (PIECE, ADD_ON; terzi kalemi 15)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, 'cd4fe896-319e-5f06-bcc2-1e81de28563a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, 'cd4fe896-319e-5f06-bcc2-1e81de28563a') AND id <> CONVERT(uniqueidentifier, 'e9282ea1-ac97-58e7-a7fd-2a431f2809e6'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P003/S014.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 60.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe') AND service_id = CONVERT(uniqueidentifier, 'cd4fe896-319e-5f06-bcc2-1e81de28563a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e9282ea1-ac97-58e7-a7fd-2a431f2809e6'), CONVERT(uniqueidentifier, '8e821699-a1d4-5042-b597-d85c5781f1fe'), CONVERT(uniqueidentifier, 'cd4fe896-319e-5f06-bcc2-1e81de28563a'), 60.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P004/S015 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, 'c564833d-7170-53ce-9d69-5b46db110362'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, 'c564833d-7170-53ce-9d69-5b46db110362') AND id <> CONVERT(uniqueidentifier, 'd8483b54-61b0-581c-8763-4b1f439d3cb7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P004/S015.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, 'c564833d-7170-53ce-9d69-5b46db110362');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd8483b54-61b0-581c-8763-4b1f439d3cb7'), CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69'), CONVERT(uniqueidentifier, 'c564833d-7170-53ce-9d69-5b46db110362'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P004/S016 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, '0ff86b2c-49e3-56ca-bbca-0c01e24a49dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, '0ff86b2c-49e3-56ca-bbca-0c01e24a49dd') AND id <> CONVERT(uniqueidentifier, '50afd079-eb07-5cb7-91de-2e7f688d5a49'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P004/S016.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, '0ff86b2c-49e3-56ca-bbca-0c01e24a49dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '50afd079-eb07-5cb7-91de-2e7f688d5a49'), CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69'), CONVERT(uniqueidentifier, '0ff86b2c-49e3-56ca-bbca-0c01e24a49dd'), 80.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P004/S017 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, 'da9a789f-fd95-57d1-aba5-2e0759cd92dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, 'da9a789f-fd95-57d1-aba5-2e0759cd92dd') AND id <> CONVERT(uniqueidentifier, '917b980c-8895-56c1-9050-b2dc3c5b4ad7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P004/S017.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, 'da9a789f-fd95-57d1-aba5-2e0759cd92dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '917b980c-8895-56c1-9050-b2dc3c5b4ad7'), CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69'), CONVERT(uniqueidentifier, 'da9a789f-fd95-57d1-aba5-2e0759cd92dd'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P004/S018 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, '611ba769-e2bf-50db-bc3c-060a0db139c8'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, '611ba769-e2bf-50db-bc3c-060a0db139c8') AND id <> CONVERT(uniqueidentifier, '9ae979af-f5b6-5179-ad67-0b8ed26e992a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P004/S018.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69') AND service_id = CONVERT(uniqueidentifier, '611ba769-e2bf-50db-bc3c-060a0db139c8');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9ae979af-f5b6-5179-ad67-0b8ed26e992a'), CONVERT(uniqueidentifier, '8cb54791-ee70-5f15-8eb4-83e2ba859e69'), CONVERT(uniqueidentifier, '611ba769-e2bf-50db-bc3c-060a0db139c8'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P005/S011 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65') AND id <> CONVERT(uniqueidentifier, '50f70561-f80a-5c0f-aa2f-09a0436ba7ce'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P005/S011.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '50f70561-f80a-5c0f-aa2f-09a0436ba7ce'), CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7'), CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'), 250.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P005/S019 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f') AND id <> CONVERT(uniqueidentifier, 'e7a74e90-b40c-5414-8618-ad2df72b5bea'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P005/S019.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 180.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e7a74e90-b40c-5414-8618-ad2df72b5bea'), CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7'), CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), 180.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P005/S020 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, '21db9ce1-27c3-524b-9af2-4e777105e4e3'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, '21db9ce1-27c3-524b-9af2-4e777105e4e3') AND id <> CONVERT(uniqueidentifier, 'bfc7efd1-8515-564b-bc93-0550ec1d42b8'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P005/S020.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 70.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7') AND service_id = CONVERT(uniqueidentifier, '21db9ce1-27c3-524b-9af2-4e777105e4e3');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'bfc7efd1-8515-564b-bc93-0550ec1d42b8'), CONVERT(uniqueidentifier, '8f8296fd-9aca-53f0-afd1-9081a46d69c7'), CONVERT(uniqueidentifier, '21db9ce1-27c3-524b-9af2-4e777105e4e3'), 70.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P006/S021 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'ad7b5cd4-352d-5856-b971-7d7a947b607e'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'ad7b5cd4-352d-5856-b971-7d7a947b607e') AND id <> CONVERT(uniqueidentifier, 'd5017b34-1f0a-5f11-9ce4-f852967dd034'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S021.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'ad7b5cd4-352d-5856-b971-7d7a947b607e');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd5017b34-1f0a-5f11-9ce4-f852967dd034'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, 'ad7b5cd4-352d-5856-b971-7d7a947b607e'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P006/S022 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a') AND id <> CONVERT(uniqueidentifier, 'ff6f3543-c19a-5afc-b344-cc7ff082d9ce'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S022.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'ff6f3543-c19a-5afc-b344-cc7ff082d9ce'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'), 80.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P006/S023 (PIECE, ADD_ON; terzi kalemi 1)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '7c3aa8c9-e1d0-5754-8679-5389db6d82c4'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '7c3aa8c9-e1d0-5754-8679-5389db6d82c4') AND id <> CONVERT(uniqueidentifier, '44afe328-3d55-5baa-89c5-dc3821d9d9d4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S023.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '7c3aa8c9-e1d0-5754-8679-5389db6d82c4');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '44afe328-3d55-5baa-89c5-dc3821d9d9d4'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, '7c3aa8c9-e1d0-5754-8679-5389db6d82c4'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P006/S024 (PIECE, ADD_ON; terzi kalemi 3)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'ba164588-634a-5c2c-b594-7c2a5fe848f1'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'ba164588-634a-5c2c-b594-7c2a5fe848f1') AND id <> CONVERT(uniqueidentifier, '136cf19a-0acf-5402-a85a-7d5e2bc3a3b4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S024.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'ba164588-634a-5c2c-b594-7c2a5fe848f1');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '136cf19a-0acf-5402-a85a-7d5e2bc3a3b4'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, 'ba164588-634a-5c2c-b594-7c2a5fe848f1'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P006/S025 (PIECE, ADD_ON; terzi kalemi 4)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '5e76ef7b-fe42-5d22-b0a7-829d1f1e0326'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '5e76ef7b-fe42-5d22-b0a7-829d1f1e0326') AND id <> CONVERT(uniqueidentifier, '0dccfd03-2663-520a-8d2d-3bc035433669'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S025.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 180.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '5e76ef7b-fe42-5d22-b0a7-829d1f1e0326');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0dccfd03-2663-520a-8d2d-3bc035433669'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, '5e76ef7b-fe42-5d22-b0a7-829d1f1e0326'), 180.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P006/S019 (PIECE, ADD_ON; terzi kalemi 5)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f') AND id <> CONVERT(uniqueidentifier, '7e1cdd23-00e7-5c8d-a751-13f490adffa7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S019.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '7e1cdd23-00e7-5c8d-a751-13f490adffa7'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P006/S026 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '261c8fc7-08a3-5993-bf4a-476b03c870ab'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '261c8fc7-08a3-5993-bf4a-476b03c870ab') AND id <> CONVERT(uniqueidentifier, '3efd0962-1f09-53d8-9888-24264d106701'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P006/S026.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 160.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f') AND service_id = CONVERT(uniqueidentifier, '261c8fc7-08a3-5993-bf4a-476b03c870ab');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '3efd0962-1f09-53d8-9888-24264d106701'), CONVERT(uniqueidentifier, 'b8fe853a-dd70-54dc-a2ae-835122b5a95f'), CONVERT(uniqueidentifier, '261c8fc7-08a3-5993-bf4a-476b03c870ab'), 160.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P007/S027 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba') AND id <> CONVERT(uniqueidentifier, '10de9ab5-8421-50e4-a9f6-d09da1cb7a60'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P007/S027.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '10de9ab5-8421-50e4-a9f6-d09da1cb7a60'), CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'), CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P007/S012 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053') AND id <> CONVERT(uniqueidentifier, '83279365-0f54-563d-9724-8d95ee7f4fd9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P007/S012.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 70.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '83279365-0f54-563d-9724-8d95ee7f4fd9'), CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'), CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'), 70.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P007/S028 (PIECE, ADD_ON; terzi kalemi 11)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd') AND id <> CONVERT(uniqueidentifier, '8181449b-f73d-5226-be79-4fc271db0ed9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P007/S028.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 130.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8181449b-f73d-5226-be79-4fc271db0ed9'), CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'), CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'), 130.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P007/S029 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, '0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, '0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1') AND id <> CONVERT(uniqueidentifier, 'c3db3f19-fbe9-5af8-9da4-6797d0b9ffb0'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P007/S029.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, '0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c3db3f19-fbe9-5af8-9da4-6797d0b9ffb0'), CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'), CONVERT(uniqueidentifier, '0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P007/S030 (PIECE, ADD_ON; terzi kalemi 5)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c') AND id <> CONVERT(uniqueidentifier, '2c8db104-6687-5bb7-b6cb-ed951d965e31'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P007/S030.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 140.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '2c8db104-6687-5bb7-b6cb-ed951d965e31'), CONVERT(uniqueidentifier, '5991b9c4-405f-594c-a9e2-67f1fbff0da1'), CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'), 140.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P008/S031 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, '2eb0a9e3-1809-5092-8652-9545002af4be'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, '2eb0a9e3-1809-5092-8652-9545002af4be') AND id <> CONVERT(uniqueidentifier, '574da846-3902-5309-9358-c19ec95141ff'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P008/S031.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, '2eb0a9e3-1809-5092-8652-9545002af4be');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '574da846-3902-5309-9358-c19ec95141ff'), CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705'), CONVERT(uniqueidentifier, '2eb0a9e3-1809-5092-8652-9545002af4be'), 250.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P008/S032 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, 'b2984dc4-904c-504a-a51e-0d65997b7069'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, 'b2984dc4-904c-504a-a51e-0d65997b7069') AND id <> CONVERT(uniqueidentifier, 'dfbe1c95-b2e4-5ffc-94d8-c6e6b6a8eedf'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P008/S032.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, 'b2984dc4-904c-504a-a51e-0d65997b7069');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'dfbe1c95-b2e4-5ffc-94d8-c6e6b6a8eedf'), CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705'), CONVERT(uniqueidentifier, 'b2984dc4-904c-504a-a51e-0d65997b7069'), 150.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P008/S033 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, '094bbf6a-c8ae-5fc7-80e0-79bd202bb395'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, '094bbf6a-c8ae-5fc7-80e0-79bd202bb395') AND id <> CONVERT(uniqueidentifier, '0f3cd1c5-f3d5-56db-b237-0e9f4e38a6d4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P008/S033.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 160.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705') AND service_id = CONVERT(uniqueidentifier, '094bbf6a-c8ae-5fc7-80e0-79bd202bb395');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0f3cd1c5-f3d5-56db-b237-0e9f4e38a6d4'), CONVERT(uniqueidentifier, '27d9a206-c352-5802-b92d-b75e58ad4705'), CONVERT(uniqueidentifier, '094bbf6a-c8ae-5fc7-80e0-79bd202bb395'), 160.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P009/S027 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba') AND id <> CONVERT(uniqueidentifier, '59f852ed-63ca-5141-809f-1d0322379f96'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P009/S027.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '59f852ed-63ca-5141-809f-1d0322379f96'), CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'), CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P009/S012 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053') AND id <> CONVERT(uniqueidentifier, '24c025ed-43ed-5245-a860-502715c13a32'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P009/S012.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '24c025ed-43ed-5245-a860-502715c13a32'), CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'), CONVERT(uniqueidentifier, '736832a0-af56-5bab-9775-455640add053'), 300.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P009/S028 (PIECE, ADD_ON; terzi kalemi 11)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd') AND id <> CONVERT(uniqueidentifier, '59b74e64-e390-5651-9a25-13dff0367972'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P009/S028.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 160.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '59b74e64-e390-5651-9a25-13dff0367972'), CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'), CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'), 160.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P009/S009 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328') AND id <> CONVERT(uniqueidentifier, 'ae25e3e4-f5ef-5555-93b4-d1336e99bd28'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P009/S009.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 180.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'ae25e3e4-f5ef-5555-93b4-d1336e99bd28'), CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'), CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'), 180.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P009/S030 (PIECE, ADD_ON; terzi kalemi 7)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c') AND id <> CONVERT(uniqueidentifier, '5400b5c1-22a2-57bd-9fb6-5bff636ad746'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P009/S030.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '5400b5c1-22a2-57bd-9fb6-5bff636ad746'), CONVERT(uniqueidentifier, 'd3455b4f-8485-5040-b02f-ff5e4c4b73bd'), CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P010/S027 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba') AND id <> CONVERT(uniqueidentifier, 'fe223abf-3dec-56aa-8691-52a119923a5e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P010/S027.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'fe223abf-3dec-56aa-8691-52a119923a5e'), CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3'), CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'), 300.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P010/S034 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820') AND id <> CONVERT(uniqueidentifier, '729bac56-74ff-5e04-bc2c-42dd679fae05'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P010/S034.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '729bac56-74ff-5e04-bc2c-42dd679fae05'), CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3'), CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P010/S035 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, '699a66f6-56ed-5c05-bdfb-f3bcbf79f00a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, '699a66f6-56ed-5c05-bdfb-f3bcbf79f00a') AND id <> CONVERT(uniqueidentifier, '338f384d-dffc-5951-835f-15235bb74d95'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P010/S035.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 140.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3') AND service_id = CONVERT(uniqueidentifier, '699a66f6-56ed-5c05-bdfb-f3bcbf79f00a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '338f384d-dffc-5951-835f-15235bb74d95'), CONVERT(uniqueidentifier, '5bc41168-949d-592e-8da3-598f7a30bcf3'), CONVERT(uniqueidentifier, '699a66f6-56ed-5c05-bdfb-f3bcbf79f00a'), 140.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P011/S011 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65') AND id <> CONVERT(uniqueidentifier, 'c6b6a2bc-f2c8-53d6-9126-17486306581d'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P011/S011.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c6b6a2bc-f2c8-53d6-9126-17486306581d'), CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174'), CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P011/S034 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820') AND id <> CONVERT(uniqueidentifier, '08366dac-04af-5597-b84a-90e7b07a4a8e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P011/S034.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '08366dac-04af-5597-b84a-90e7b07a4a8e'), CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174'), CONVERT(uniqueidentifier, 'bc5d02e7-dfd8-5c67-8125-f999011fc820'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P011/S036 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, '5f4258af-012d-577e-a7ea-c9b3a506dbdc'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, '5f4258af-012d-577e-a7ea-c9b3a506dbdc') AND id <> CONVERT(uniqueidentifier, '79cf69f8-7941-5883-bc9a-f084e7ccb1ae'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P011/S036.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 110.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174') AND service_id = CONVERT(uniqueidentifier, '5f4258af-012d-577e-a7ea-c9b3a506dbdc');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '79cf69f8-7941-5883-bc9a-f084e7ccb1ae'), CONVERT(uniqueidentifier, 'd9a7e88c-69ca-55da-a4c4-2b71c6d34174'), CONVERT(uniqueidentifier, '5f4258af-012d-577e-a7ea-c9b3a506dbdc'), 110.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P012/S037 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '563006fb-e70f-51df-b266-64822f63ad02'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '563006fb-e70f-51df-b266-64822f63ad02') AND id <> CONVERT(uniqueidentifier, '63820a60-91b6-5a1f-9863-71d2052dfa8e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012/S037.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '563006fb-e70f-51df-b266-64822f63ad02');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '63820a60-91b6-5a1f-9863-71d2052dfa8e'), CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, '563006fb-e70f-51df-b266-64822f63ad02'), 300.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P012/S022 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a') AND id <> CONVERT(uniqueidentifier, 'f87ee92d-0857-5c96-a11f-075d1d09bc6c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012/S022.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'f87ee92d-0857-5c96-a11f-075d1d09bc6c'), CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'), 100.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P012/S038 (PIECE, ADD_ON; terzi kalemi 8)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '0b15470c-8116-55e4-bc3a-e407ff91cd7b'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '0b15470c-8116-55e4-bc3a-e407ff91cd7b') AND id <> CONVERT(uniqueidentifier, '17554fce-8570-507b-86db-bb3519e28741'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012/S038.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '0b15470c-8116-55e4-bc3a-e407ff91cd7b');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '17554fce-8570-507b-86db-bb3519e28741'), CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, '0b15470c-8116-55e4-bc3a-e407ff91cd7b'), 200.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P012/S039 (PIECE, ADD_ON; terzi kalemi 9)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '59590b50-617b-55e2-86bf-01abf06e0a87'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '59590b50-617b-55e2-86bf-01abf06e0a87') AND id <> CONVERT(uniqueidentifier, '4f674ff0-1364-5e5e-b49c-00b31038a6a7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012/S039.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 280.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '59590b50-617b-55e2-86bf-01abf06e0a87');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '4f674ff0-1364-5e5e-b49c-00b31038a6a7'), CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, '59590b50-617b-55e2-86bf-01abf06e0a87'), 280.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P012/S009 (PIECE, ADD_ON; terzi kalemi 13)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328') AND id <> CONVERT(uniqueidentifier, 'aec03478-fcf5-54ad-8262-7a7a16d5ad99'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012/S009.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'aec03478-fcf5-54ad-8262-7a7a16d5ad99'), CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, '8648a6fb-443f-5362-9737-4df86858a328'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P012/S040 (PIECE, ADD_ON; terzi kalemi 15)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c') AND id <> CONVERT(uniqueidentifier, 'a42fbb7f-2de2-54f5-a2c6-27ca79375a02'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P012/S040.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c') AND service_id = CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'a42fbb7f-2de2-54f5-a2c6-27ca79375a02'), CONVERT(uniqueidentifier, '4103433a-c429-54e0-98ec-88411a85e50c'), CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P013/S041 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '41d37138-5011-5fbf-8fe9-0f45ec14cf2f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '41d37138-5011-5fbf-8fe9-0f45ec14cf2f') AND id <> CONVERT(uniqueidentifier, '4d2ff2c1-327f-5fad-abd7-d1ead1a29b48'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013/S041.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '41d37138-5011-5fbf-8fe9-0f45ec14cf2f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '4d2ff2c1-327f-5fad-abd7-d1ead1a29b48'), CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, '41d37138-5011-5fbf-8fe9-0f45ec14cf2f'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P013/S042 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, 'b1f37ddc-c005-5556-a0c5-ac806978f0bc'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, 'b1f37ddc-c005-5556-a0c5-ac806978f0bc') AND id <> CONVERT(uniqueidentifier, 'b074b5d6-38b6-57fa-8008-fae6efb61626'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013/S042.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, 'b1f37ddc-c005-5556-a0c5-ac806978f0bc');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b074b5d6-38b6-57fa-8008-fae6efb61626'), CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, 'b1f37ddc-c005-5556-a0c5-ac806978f0bc'), 200.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P013/S043 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '0e695b64-2889-5fe3-b6a4-aa680d63363b'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '0e695b64-2889-5fe3-b6a4-aa680d63363b') AND id <> CONVERT(uniqueidentifier, 'e12616c7-566e-5af0-abf0-837afbb6bda3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013/S043.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '0e695b64-2889-5fe3-b6a4-aa680d63363b');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e12616c7-566e-5af0-abf0-837afbb6bda3'), CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, '0e695b64-2889-5fe3-b6a4-aa680d63363b'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P013/S028 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd') AND id <> CONVERT(uniqueidentifier, 'd2716a12-4119-5418-ba22-5b12ccdae116'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013/S028.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd2716a12-4119-5418-ba22-5b12ccdae116'), CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'), 300.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P013/S044 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '8e73dff7-96f2-5030-901c-ec53f30e2ae2'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '8e73dff7-96f2-5030-901c-ec53f30e2ae2') AND id <> CONVERT(uniqueidentifier, '608b1e3f-d39c-50bf-bc19-fadcab18d4ad'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013/S044.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 450.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '8e73dff7-96f2-5030-901c-ec53f30e2ae2');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '608b1e3f-d39c-50bf-bc19-fadcab18d4ad'), CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, '8e73dff7-96f2-5030-901c-ec53f30e2ae2'), 450.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P013/S045 (PIECE, ADD_ON; terzi kalemi 16)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '8c0c364f-7732-5cde-97cd-4c69fefd032d'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '8c0c364f-7732-5cde-97cd-4c69fefd032d') AND id <> CONVERT(uniqueidentifier, '8d0ae8ac-80dd-5dc4-a692-2bea4d6ebda9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P013/S045.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 50.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb') AND service_id = CONVERT(uniqueidentifier, '8c0c364f-7732-5cde-97cd-4c69fefd032d');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8d0ae8ac-80dd-5dc4-a692-2bea4d6ebda9'), CONVERT(uniqueidentifier, 'a360713d-4870-51bd-8c54-3b3fc55ce5fb'), CONVERT(uniqueidentifier, '8c0c364f-7732-5cde-97cd-4c69fefd032d'), 50.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P014/S027 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba') AND id <> CONVERT(uniqueidentifier, '5155d4f0-23de-5908-adbb-def2b9849af7'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P014/S027.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '5155d4f0-23de-5908-adbb-def2b9849af7'), CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39'), CONVERT(uniqueidentifier, 'd8aa6e63-2a06-5f36-9934-fda929c05fba'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P014/S046 (PIECE, ADD_ON; terzi kalemi 6)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, '66c63af4-1a42-5ac4-aa2b-05c210686f8d'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, '66c63af4-1a42-5ac4-aa2b-05c210686f8d') AND id <> CONVERT(uniqueidentifier, '9524a1d4-1766-533e-9b69-20bde4c4449e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P014/S046.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, '66c63af4-1a42-5ac4-aa2b-05c210686f8d');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9524a1d4-1766-533e-9b69-20bde4c4449e'), CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39'), CONVERT(uniqueidentifier, '66c63af4-1a42-5ac4-aa2b-05c210686f8d'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P014/S047 (PIECE, ADD_ON; terzi kalemi 15)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, 'c070a9c1-cce2-519a-9e15-441e5210c83d'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, 'c070a9c1-cce2-519a-9e15-441e5210c83d') AND id <> CONVERT(uniqueidentifier, '7c1740b7-e861-50be-a3be-fe3541c637b4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P014/S047.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39') AND service_id = CONVERT(uniqueidentifier, 'c070a9c1-cce2-519a-9e15-441e5210c83d');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '7c1740b7-e861-50be-a3be-fe3541c637b4'), CONVERT(uniqueidentifier, 'f789e5a8-dc1b-5000-95d6-822040c7ba39'), CONVERT(uniqueidentifier, 'c070a9c1-cce2-519a-9e15-441e5210c83d'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P015/S048 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, '609afdd2-772e-5541-bc6c-96be9f041aae'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, '609afdd2-772e-5541-bc6c-96be9f041aae') AND id <> CONVERT(uniqueidentifier, '56f34399-90e5-5a15-bd72-be1d49760eab'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P015/S048.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 550.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, '609afdd2-772e-5541-bc6c-96be9f041aae');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '56f34399-90e5-5a15-bd72-be1d49760eab'), CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0'), CONVERT(uniqueidentifier, '609afdd2-772e-5541-bc6c-96be9f041aae'), 550.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P015/S019 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f') AND id <> CONVERT(uniqueidentifier, '0d422cef-735c-512d-adf3-e747668674d5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P015/S019.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0d422cef-735c-512d-adf3-e747668674d5'), CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0'), CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P015/S049 (PIECE, ADD_ON; terzi kalemi 15)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, '6650cb67-716b-549e-ac5a-bd7897c7513f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, '6650cb67-716b-549e-ac5a-bd7897c7513f') AND id <> CONVERT(uniqueidentifier, '9d050108-7954-5128-89ba-f71f41a72ae0'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P015/S049.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 180.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0') AND service_id = CONVERT(uniqueidentifier, '6650cb67-716b-549e-ac5a-bd7897c7513f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9d050108-7954-5128-89ba-f71f41a72ae0'), CONVERT(uniqueidentifier, '46830851-0a16-582e-b6d1-ba195ac1efa0'), CONVERT(uniqueidentifier, '6650cb67-716b-549e-ac5a-bd7897c7513f'), 180.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P016/S050 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d') AND service_id = CONVERT(uniqueidentifier, '9c397969-7be5-5df2-a4e0-48039b8c24aa'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d') AND service_id = CONVERT(uniqueidentifier, '9c397969-7be5-5df2-a4e0-48039b8c24aa') AND id <> CONVERT(uniqueidentifier, 'b6311b21-6349-5ed5-960d-7f58d97730d4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P016/S050.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 600.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d') AND service_id = CONVERT(uniqueidentifier, '9c397969-7be5-5df2-a4e0-48039b8c24aa');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b6311b21-6349-5ed5-960d-7f58d97730d4'), CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d'), CONVERT(uniqueidentifier, '9c397969-7be5-5df2-a4e0-48039b8c24aa'), 600.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P016/S051 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d') AND service_id = CONVERT(uniqueidentifier, '1424f776-c630-5a22-9a85-e6987d2ffc0c'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d') AND service_id = CONVERT(uniqueidentifier, '1424f776-c630-5a22-9a85-e6987d2ffc0c') AND id <> CONVERT(uniqueidentifier, '783fd686-6815-572f-b7b0-62cb28e15082'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P016/S051.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 320.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d') AND service_id = CONVERT(uniqueidentifier, '1424f776-c630-5a22-9a85-e6987d2ffc0c');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '783fd686-6815-572f-b7b0-62cb28e15082'), CONVERT(uniqueidentifier, '8fcecc5d-16d0-58df-ba68-74c2c538af0d'), CONVERT(uniqueidentifier, '1424f776-c630-5a22-9a85-e6987d2ffc0c'), 320.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P017/S052 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08') AND service_id = CONVERT(uniqueidentifier, '05aeb3f9-f2f6-56e7-9292-e4e26bce0715'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08') AND service_id = CONVERT(uniqueidentifier, '05aeb3f9-f2f6-56e7-9292-e4e26bce0715') AND id <> CONVERT(uniqueidentifier, '8a15cd99-5175-5910-916a-174216e063df'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P017/S052.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08') AND service_id = CONVERT(uniqueidentifier, '05aeb3f9-f2f6-56e7-9292-e4e26bce0715');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8a15cd99-5175-5910-916a-174216e063df'), CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08'), CONVERT(uniqueidentifier, '05aeb3f9-f2f6-56e7-9292-e4e26bce0715'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P017/S019 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f') AND id <> CONVERT(uniqueidentifier, '4653c153-4e21-56ad-aee0-9c63d6334cdb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P017/S019.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '4653c153-4e21-56ad-aee0-9c63d6334cdb'), CONVERT(uniqueidentifier, '618c3741-1d58-5495-bd54-1c395ff65a08'), CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), 200.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P018/S053 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '176e4cf8-e704-596b-aa28-018b698dc755'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '176e4cf8-e704-596b-aa28-018b698dc755') AND id <> CONVERT(uniqueidentifier, '40f34b21-8dda-5814-99b7-353ef4780ed5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P018/S053.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '176e4cf8-e704-596b-aa28-018b698dc755');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '40f34b21-8dda-5814-99b7-353ef4780ed5'), CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a'), CONVERT(uniqueidentifier, '176e4cf8-e704-596b-aa28-018b698dc755'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P018/S054 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '4ad2db46-3f0b-5d90-ae82-93ff1fb94172'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '4ad2db46-3f0b-5d90-ae82-93ff1fb94172') AND id <> CONVERT(uniqueidentifier, 'ea064f7c-39f8-59ce-81a9-b63000e556b9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P018/S054.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '4ad2db46-3f0b-5d90-ae82-93ff1fb94172');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'ea064f7c-39f8-59ce-81a9-b63000e556b9'), CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a'), CONVERT(uniqueidentifier, '4ad2db46-3f0b-5d90-ae82-93ff1fb94172'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P018/S055 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '1219e2ed-0953-5ef7-864c-4a9899337f46'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '1219e2ed-0953-5ef7-864c-4a9899337f46') AND id <> CONVERT(uniqueidentifier, '6072d329-4b6f-5eaa-bff6-7a5b05e51305'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P018/S055.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 240.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '1219e2ed-0953-5ef7-864c-4a9899337f46');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6072d329-4b6f-5eaa-bff6-7a5b05e51305'), CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a'), CONVERT(uniqueidentifier, '1219e2ed-0953-5ef7-864c-4a9899337f46'), 240.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P018/S056 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '3ad4f605-fe02-5bd0-b07f-e9f774dafc0a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '3ad4f605-fe02-5bd0-b07f-e9f774dafc0a') AND id <> CONVERT(uniqueidentifier, '9ba28051-19f5-5c22-a971-2852d514e38b'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P018/S056.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a') AND service_id = CONVERT(uniqueidentifier, '3ad4f605-fe02-5bd0-b07f-e9f774dafc0a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9ba28051-19f5-5c22-a971-2852d514e38b'), CONVERT(uniqueidentifier, '7242fead-4555-5a9a-b3f7-572dc837987a'), CONVERT(uniqueidentifier, '3ad4f605-fe02-5bd0-b07f-e9f774dafc0a'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P019/S057 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '2e77d708-5fa6-54d1-bc4e-3bafbc0546bf'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '2e77d708-5fa6-54d1-bc4e-3bafbc0546bf') AND id <> CONVERT(uniqueidentifier, '6574f45c-ad9b-59d6-9fa3-20cc0bb6a8a4'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P019/S057.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '2e77d708-5fa6-54d1-bc4e-3bafbc0546bf');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6574f45c-ad9b-59d6-9fa3-20cc0bb6a8a4'), CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68'), CONVERT(uniqueidentifier, '2e77d708-5fa6-54d1-bc4e-3bafbc0546bf'), 1000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P019/S058 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '6418be14-d7d7-5f1d-8529-05290fc827ce'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '6418be14-d7d7-5f1d-8529-05290fc827ce') AND id <> CONVERT(uniqueidentifier, 'a7554c7c-ac36-58b6-99e0-8f38a132f769'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P019/S058.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 550.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '6418be14-d7d7-5f1d-8529-05290fc827ce');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'a7554c7c-ac36-58b6-99e0-8f38a132f769'), CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68'), CONVERT(uniqueidentifier, '6418be14-d7d7-5f1d-8529-05290fc827ce'), 550.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P019/S059 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '30fa771e-8552-5625-81b0-77204a320daa'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '30fa771e-8552-5625-81b0-77204a320daa') AND id <> CONVERT(uniqueidentifier, 'b74b3ccd-9faf-5c24-ae04-2e6d6b9e4fe5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P019/S059.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '30fa771e-8552-5625-81b0-77204a320daa');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b74b3ccd-9faf-5c24-ae04-2e6d6b9e4fe5'), CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68'), CONVERT(uniqueidentifier, '30fa771e-8552-5625-81b0-77204a320daa'), 350.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P019/S060 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '0fdcfbe7-1292-590c-aa48-0ad68e140f72'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '0fdcfbe7-1292-590c-aa48-0ad68e140f72') AND id <> CONVERT(uniqueidentifier, '6d3e58f0-1c81-5b89-beda-808d9c7c2bdb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P019/S060.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 400.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68') AND service_id = CONVERT(uniqueidentifier, '0fdcfbe7-1292-590c-aa48-0ad68e140f72');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6d3e58f0-1c81-5b89-beda-808d9c7c2bdb'), CONVERT(uniqueidentifier, '6b9afd98-e8b8-5190-997b-4db61110ef68'), CONVERT(uniqueidentifier, '0fdcfbe7-1292-590c-aa48-0ad68e140f72'), 400.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P020/S061 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd') AND service_id = CONVERT(uniqueidentifier, '8f54536c-31b1-51c7-acdd-810dc8d9e32a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd') AND service_id = CONVERT(uniqueidentifier, '8f54536c-31b1-51c7-acdd-810dc8d9e32a') AND id <> CONVERT(uniqueidentifier, 'd1cfdc23-5081-5baa-af9f-e0edd8519ccb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P020/S061.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd') AND service_id = CONVERT(uniqueidentifier, '8f54536c-31b1-51c7-acdd-810dc8d9e32a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd1cfdc23-5081-5baa-af9f-e0edd8519ccb'), CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd'), CONVERT(uniqueidentifier, '8f54536c-31b1-51c7-acdd-810dc8d9e32a'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P020/S019 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f') AND id <> CONVERT(uniqueidentifier, '8ca30afc-77b5-5028-8e1f-5d23ccc66b74'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P020/S019.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 220.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8ca30afc-77b5-5028-8e1f-5d23ccc66b74'), CONVERT(uniqueidentifier, 'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd'), CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), 220.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P021/S062 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38') AND service_id = CONVERT(uniqueidentifier, '8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38') AND service_id = CONVERT(uniqueidentifier, '8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8') AND id <> CONVERT(uniqueidentifier, '9c746a8f-56ff-5c79-91d5-980dc9811ca8'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P021/S062.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38') AND service_id = CONVERT(uniqueidentifier, '8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9c746a8f-56ff-5c79-91d5-980dc9811ca8'), CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38'), CONVERT(uniqueidentifier, '8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8'), 1000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P021/S063 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38') AND service_id = CONVERT(uniqueidentifier, 'f8c3584c-7f2c-5d69-98eb-35866aac0b1a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38') AND service_id = CONVERT(uniqueidentifier, 'f8c3584c-7f2c-5d69-98eb-35866aac0b1a') AND id <> CONVERT(uniqueidentifier, '47ec2fc6-bd1a-575f-a50e-a154e97f5c9f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P021/S063.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38') AND service_id = CONVERT(uniqueidentifier, 'f8c3584c-7f2c-5d69-98eb-35866aac0b1a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '47ec2fc6-bd1a-575f-a50e-a154e97f5c9f'), CONVERT(uniqueidentifier, '6e8184f8-4874-536f-8a0c-3ac81e9b8f38'), CONVERT(uniqueidentifier, 'f8c3584c-7f2c-5d69-98eb-35866aac0b1a'), 300.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P022/S064 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1') AND id <> CONVERT(uniqueidentifier, '863a783a-9e73-50f0-94bb-adb40ee82478'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P022/S064.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '863a783a-9e73-50f0-94bb-adb40ee82478'), CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163'), CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1'), 1500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P022/S065 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb') AND id <> CONVERT(uniqueidentifier, '0c952486-3471-5264-bbff-bae0e9fadc7e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P022/S065.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0c952486-3471-5264-bbff-bae0e9fadc7e'), CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163'), CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P022/S066 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee') AND id <> CONVERT(uniqueidentifier, '6d1df6b4-1b13-5e92-b297-fe12a8378e97'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P022/S066.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163') AND service_id = CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6d1df6b4-1b13-5e92-b297-fe12a8378e97'), CONVERT(uniqueidentifier, '65d09160-7a43-51d3-a033-8a2ac609d163'), CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee'), 350.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P023/S064 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1') AND id <> CONVERT(uniqueidentifier, '493267bd-6649-59fe-8a2c-d182cb3aa942'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P023/S064.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '493267bd-6649-59fe-8a2c-d182cb3aa942'), CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680'), CONVERT(uniqueidentifier, 'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1'), 1000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P023/S065 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb') AND id <> CONVERT(uniqueidentifier, '4ddd086b-60ac-5c71-b08b-48c6e267a7b0'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P023/S065.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '4ddd086b-60ac-5c71-b08b-48c6e267a7b0'), CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680'), CONVERT(uniqueidentifier, 'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P023/S066 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee') AND id <> CONVERT(uniqueidentifier, 'b3f197ec-0dfa-574a-a851-487f7d9547dd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P023/S066.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680') AND service_id = CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b3f197ec-0dfa-574a-a851-487f7d9547dd'), CONVERT(uniqueidentifier, '3cd13fdf-8cf3-54c6-a0b8-221bcdda8680'), CONVERT(uniqueidentifier, '1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee'), 350.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P024/S067 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0') AND service_id = CONVERT(uniqueidentifier, 'ed75dc26-1195-575d-9449-a9f24130bed4'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0') AND service_id = CONVERT(uniqueidentifier, 'ed75dc26-1195-575d-9449-a9f24130bed4') AND id <> CONVERT(uniqueidentifier, '4d8ecb3c-2d77-551c-90fa-bb3937d74d85'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P024/S067.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0') AND service_id = CONVERT(uniqueidentifier, 'ed75dc26-1195-575d-9449-a9f24130bed4');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '4d8ecb3c-2d77-551c-90fa-bb3937d74d85'), CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0'), CONVERT(uniqueidentifier, 'ed75dc26-1195-575d-9449-a9f24130bed4'), 1000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P024/S068 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0') AND service_id = CONVERT(uniqueidentifier, 'e495909b-79af-5e80-a006-84d850bda911'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0') AND service_id = CONVERT(uniqueidentifier, 'e495909b-79af-5e80-a006-84d850bda911') AND id <> CONVERT(uniqueidentifier, '5a6085a2-051e-527f-9c01-402b4f428eb1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P024/S068.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 400.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0') AND service_id = CONVERT(uniqueidentifier, 'e495909b-79af-5e80-a006-84d850bda911');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '5a6085a2-051e-527f-9c01-402b4f428eb1'), CONVERT(uniqueidentifier, '774b715d-57f9-5847-ab16-3b18e739adc0'), CONVERT(uniqueidentifier, 'e495909b-79af-5e80-a006-84d850bda911'), 400.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P025/S069 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, '81732f9b-beec-540e-aafe-4bd8a8d63119'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, '81732f9b-beec-540e-aafe-4bd8a8d63119') AND id <> CONVERT(uniqueidentifier, '030afc3d-df92-5fe6-9c18-5259e323faba'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P025/S069.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, '81732f9b-beec-540e-aafe-4bd8a8d63119');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '030afc3d-df92-5fe6-9c18-5259e323faba'), CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'), CONVERT(uniqueidentifier, '81732f9b-beec-540e-aafe-4bd8a8d63119'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P025/S022 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a') AND id <> CONVERT(uniqueidentifier, 'c6d4b337-383a-5a8a-a165-37dca0d706e3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P025/S022.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c6d4b337-383a-5a8a-a165-37dca0d706e3'), CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'), CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'), 200.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P025/S070 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'f067cbfb-660a-5f13-b80e-64ec0997ecfe'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'f067cbfb-660a-5f13-b80e-64ec0997ecfe') AND id <> CONVERT(uniqueidentifier, '2d674d78-868a-5370-91e4-7d6799733bbc'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P025/S070.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'f067cbfb-660a-5f13-b80e-64ec0997ecfe');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '2d674d78-868a-5370-91e4-7d6799733bbc'), CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'), CONVERT(uniqueidentifier, 'f067cbfb-660a-5f13-b80e-64ec0997ecfe'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P025/S071 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, '9d88b3d2-f617-54a0-9c4d-740f4c3ed946'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, '9d88b3d2-f617-54a0-9c4d-740f4c3ed946') AND id <> CONVERT(uniqueidentifier, 'c49cc561-41f7-5d6c-af74-40ff9a6aa3f1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P025/S071.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 180.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, '9d88b3d2-f617-54a0-9c4d-740f4c3ed946');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c49cc561-41f7-5d6c-af74-40ff9a6aa3f1'), CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'), CONVERT(uniqueidentifier, '9d88b3d2-f617-54a0-9c4d-740f4c3ed946'), 180.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P025/S072 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'a04acb35-29d5-5bfd-96a6-c501670049f2'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'a04acb35-29d5-5bfd-96a6-c501670049f2') AND id <> CONVERT(uniqueidentifier, 'cf81797f-bff3-5384-b7c3-c0188311f3b5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P025/S072.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14') AND service_id = CONVERT(uniqueidentifier, 'a04acb35-29d5-5bfd-96a6-c501670049f2');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'cf81797f-bff3-5384-b7c3-c0188311f3b5'), CONVERT(uniqueidentifier, 'bcefdefb-46dd-53b9-8b69-fb0434698f14'), CONVERT(uniqueidentifier, 'a04acb35-29d5-5bfd-96a6-c501670049f2'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P026/S073 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, '35d552ba-dccb-54a4-b722-5ad9b91495e1'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, '35d552ba-dccb-54a4-b722-5ad9b91495e1') AND id <> CONVERT(uniqueidentifier, '0be51b4c-73b1-5292-a599-e8729450fd64'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P026/S073.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 600.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, '35d552ba-dccb-54a4-b722-5ad9b91495e1');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0be51b4c-73b1-5292-a599-e8729450fd64'), CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36'), CONVERT(uniqueidentifier, '35d552ba-dccb-54a4-b722-5ad9b91495e1'), 600.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P026/S022 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a') AND id <> CONVERT(uniqueidentifier, 'da0599ce-a729-5a3f-8a4e-1ba1a2f3d0cc'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P026/S022.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'da0599ce-a729-5a3f-8a4e-1ba1a2f3d0cc'), CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36'), CONVERT(uniqueidentifier, 'c6418fae-c610-52c4-a0e0-1a254dedcc1a'), 250.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P026/S074 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, 'f6060f16-0ff7-5cd5-879b-01e4f22b3f28'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, 'f6060f16-0ff7-5cd5-879b-01e4f22b3f28') AND id <> CONVERT(uniqueidentifier, 'c19a11a7-c2cc-5bd2-8f8a-926588a9fa81'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P026/S074.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 450.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36') AND service_id = CONVERT(uniqueidentifier, 'f6060f16-0ff7-5cd5-879b-01e4f22b3f28');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c19a11a7-c2cc-5bd2-8f8a-926588a9fa81'), CONVERT(uniqueidentifier, '6856b51b-29aa-5583-922e-f9e0538fde36'), CONVERT(uniqueidentifier, 'f6060f16-0ff7-5cd5-879b-01e4f22b3f28'), 450.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P027/S075 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, '1ee68bf0-8fc4-5769-9278-178b31f83abf'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, '1ee68bf0-8fc4-5769-9278-178b31f83abf') AND id <> CONVERT(uniqueidentifier, '2c95e22e-863d-5d58-b5d8-daaa88c160dd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P027/S075.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 800.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, '1ee68bf0-8fc4-5769-9278-178b31f83abf');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '2c95e22e-863d-5d58-b5d8-daaa88c160dd'), CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'), CONVERT(uniqueidentifier, '1ee68bf0-8fc4-5769-9278-178b31f83abf'), 800.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P027/S076 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69') AND id <> CONVERT(uniqueidentifier, '58656a47-402c-5f34-9b72-8845fa5e87ed'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P027/S076.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '58656a47-402c-5f34-9b72-8845fa5e87ed'), CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'), CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'), 250.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P027/S028 (PIECE, ADD_ON; terzi kalemi 11)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd') AND id <> CONVERT(uniqueidentifier, 'b6d8630b-f174-5c78-abab-e8ac685988d0'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P027/S028.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b6d8630b-f174-5c78-abab-e8ac685988d0'), CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'), CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'), 200.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P027/S077 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, '9e6cb8ea-367a-5df5-a378-56981029751a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, '9e6cb8ea-367a-5df5-a378-56981029751a') AND id <> CONVERT(uniqueidentifier, 'bc32c8cb-5acf-5944-9122-aeeace094080'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P027/S077.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, '9e6cb8ea-367a-5df5-a378-56981029751a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'bc32c8cb-5acf-5944-9122-aeeace094080'), CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'), CONVERT(uniqueidentifier, '9e6cb8ea-367a-5df5-a378-56981029751a'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P027/S078 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'd829249a-8913-5eb7-8784-f08b4dfb3214'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'd829249a-8913-5eb7-8784-f08b4dfb3214') AND id <> CONVERT(uniqueidentifier, '215e3c16-6628-5246-8a75-c68288c60b61'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P027/S078.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a') AND service_id = CONVERT(uniqueidentifier, 'd829249a-8913-5eb7-8784-f08b4dfb3214');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '215e3c16-6628-5246-8a75-c68288c60b61'), CONVERT(uniqueidentifier, 'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a'), CONVERT(uniqueidentifier, 'd829249a-8913-5eb7-8784-f08b4dfb3214'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P028/S079 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, '37f584ca-3203-5713-81c4-6d0c81e00c3e'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, '37f584ca-3203-5713-81c4-6d0c81e00c3e') AND id <> CONVERT(uniqueidentifier, '6a4f3cb2-2f67-5375-8eb1-d7040e7facdc'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P028/S079.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, '37f584ca-3203-5713-81c4-6d0c81e00c3e');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6a4f3cb2-2f67-5375-8eb1-d7040e7facdc'), CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'), CONVERT(uniqueidentifier, '37f584ca-3203-5713-81c4-6d0c81e00c3e'), 1200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P028/S076 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69') AND id <> CONVERT(uniqueidentifier, 'eb467644-5a47-5166-9a5a-5aa0b15445ee'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P028/S076.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'eb467644-5a47-5166-9a5a-5aa0b15445ee'), CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'), CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'), 350.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P028/S080 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, '7742e586-122d-5cd4-b414-196fc5c3f513'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, '7742e586-122d-5cd4-b414-196fc5c3f513') AND id <> CONVERT(uniqueidentifier, '4dfa249c-c972-5177-afe0-dc176347ba7c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P028/S080.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, '7742e586-122d-5cd4-b414-196fc5c3f513');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '4dfa249c-c972-5177-afe0-dc176347ba7c'), CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'), CONVERT(uniqueidentifier, '7742e586-122d-5cd4-b414-196fc5c3f513'), 350.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P028/S081 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'fa93fb50-bd3c-5cba-8690-7a2cb5161c68'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'fa93fb50-bd3c-5cba-8690-7a2cb5161c68') AND id <> CONVERT(uniqueidentifier, 'b7c1896f-6c7e-55e4-8624-a87f7804654f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P028/S081.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'fa93fb50-bd3c-5cba-8690-7a2cb5161c68');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b7c1896f-6c7e-55e4-8624-a87f7804654f'), CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'), CONVERT(uniqueidentifier, 'fa93fb50-bd3c-5cba-8690-7a2cb5161c68'), 200.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P028/S030 (PIECE, ADD_ON; terzi kalemi 7)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c') AND id <> CONVERT(uniqueidentifier, '9aa6767b-98ad-55c2-88dc-6abbeafcf752'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P028/S030.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 180.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38') AND service_id = CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9aa6767b-98ad-55c2-88dc-6abbeafcf752'), CONVERT(uniqueidentifier, '50055790-3ee1-5d51-b802-b4998fdb9a38'), CONVERT(uniqueidentifier, 'cdb16ee9-234b-5d20-9138-d8a08a5cb20c'), 180.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P029/S082 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, '5cd4a254-ddb8-5897-bbb1-6a4eee015437'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, '5cd4a254-ddb8-5897-bbb1-6a4eee015437') AND id <> CONVERT(uniqueidentifier, '86c829f0-0c76-5b7f-b800-a90f6483280f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P029/S082.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 3000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, '5cd4a254-ddb8-5897-bbb1-6a4eee015437');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '86c829f0-0c76-5b7f-b800-a90f6483280f'), CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068'), CONVERT(uniqueidentifier, '5cd4a254-ddb8-5897-bbb1-6a4eee015437'), 3000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P029/S076 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69') AND id <> CONVERT(uniqueidentifier, '8b89b1cb-30db-5581-9db3-70470b0f4877'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P029/S076.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8b89b1cb-30db-5581-9db3-70470b0f4877'), CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068'), CONVERT(uniqueidentifier, 'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69'), 1000.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P029/S083 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, '6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, '6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671') AND id <> CONVERT(uniqueidentifier, 'af46f290-d53d-580d-b689-7425f95914ee'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P029/S083.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068') AND service_id = CONVERT(uniqueidentifier, '6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'af46f290-d53d-580d-b689-7425f95914ee'), CONVERT(uniqueidentifier, '35c1190a-69aa-5d57-859a-dbd21f98e068'), CONVERT(uniqueidentifier, '6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671'), 500.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P030/S084 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'cf76c324-dc08-581a-a9c6-7c72de3be743'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'cf76c324-dc08-581a-a9c6-7c72de3be743') AND id <> CONVERT(uniqueidentifier, '06acef67-3bb7-5d67-b0a4-a22080df5b48'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P030/S084.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 4000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'cf76c324-dc08-581a-a9c6-7c72de3be743');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '06acef67-3bb7-5d67-b0a4-a22080df5b48'), CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156'), CONVERT(uniqueidentifier, 'cf76c324-dc08-581a-a9c6-7c72de3be743'), 4000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P030/S085 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'e802bbab-75a6-5df3-aa8b-6e905bee20c6'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'e802bbab-75a6-5df3-aa8b-6e905bee20c6') AND id <> CONVERT(uniqueidentifier, 'c8dd76de-c741-52b7-92ec-24c066fe1322'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P030/S085.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 400.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'e802bbab-75a6-5df3-aa8b-6e905bee20c6');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c8dd76de-c741-52b7-92ec-24c066fe1322'), CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156'), CONVERT(uniqueidentifier, 'e802bbab-75a6-5df3-aa8b-6e905bee20c6'), 400.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P030/S086 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a') AND id <> CONVERT(uniqueidentifier, 'b2c486e8-05f5-541e-9ba6-dbf26304520a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P030/S086.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 700.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156') AND service_id = CONVERT(uniqueidentifier, 'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b2c486e8-05f5-541e-9ba6-dbf26304520a'), CONVERT(uniqueidentifier, '57e92e2a-488b-5814-8896-c6fc64380156'), CONVERT(uniqueidentifier, 'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a'), 700.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P031/S087 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69') AND service_id = CONVERT(uniqueidentifier, '1e2e5bab-8745-5351-8652-601e4fe2d4a2'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69') AND service_id = CONVERT(uniqueidentifier, '1e2e5bab-8745-5351-8652-601e4fe2d4a2') AND id <> CONVERT(uniqueidentifier, '8324c683-80ee-55ca-9c2c-b23094838390'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P031/S087.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 900.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69') AND service_id = CONVERT(uniqueidentifier, '1e2e5bab-8745-5351-8652-601e4fe2d4a2');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8324c683-80ee-55ca-9c2c-b23094838390'), CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69'), CONVERT(uniqueidentifier, '1e2e5bab-8745-5351-8652-601e4fe2d4a2'), 900.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P031/S088 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69') AND service_id = CONVERT(uniqueidentifier, 'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69') AND service_id = CONVERT(uniqueidentifier, 'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70') AND id <> CONVERT(uniqueidentifier, '5ad19d24-c98a-538e-b174-5e3914b6a6dd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P031/S088.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 250.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69') AND service_id = CONVERT(uniqueidentifier, 'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '5ad19d24-c98a-538e-b174-5e3914b6a6dd'), CONVERT(uniqueidentifier, '420cad67-4fe1-57a6-b066-c9a00f3ceb69'), CONVERT(uniqueidentifier, 'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70'), 250.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P032/S089 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66') AND service_id = CONVERT(uniqueidentifier, '0dea4e35-e64a-5b4e-bde7-23e73d7d3262'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66') AND service_id = CONVERT(uniqueidentifier, '0dea4e35-e64a-5b4e-bde7-23e73d7d3262') AND id <> CONVERT(uniqueidentifier, '9ce6c74d-af52-5636-b316-3fa39a9e1482'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P032/S089.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66') AND service_id = CONVERT(uniqueidentifier, '0dea4e35-e64a-5b4e-bde7-23e73d7d3262');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9ce6c74d-af52-5636-b316-3fa39a9e1482'), CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66'), CONVERT(uniqueidentifier, '0dea4e35-e64a-5b4e-bde7-23e73d7d3262'), 300.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P032/S090 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66') AND service_id = CONVERT(uniqueidentifier, 'c3a49d43-a07c-5ccd-850e-d110a225d2ab'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66') AND service_id = CONVERT(uniqueidentifier, 'c3a49d43-a07c-5ccd-850e-d110a225d2ab') AND id <> CONVERT(uniqueidentifier, '28958333-f05f-5ce7-a09e-390c5907689e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P032/S090.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66') AND service_id = CONVERT(uniqueidentifier, 'c3a49d43-a07c-5ccd-850e-d110a225d2ab');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '28958333-f05f-5ce7-a09e-390c5907689e'), CONVERT(uniqueidentifier, 'ec56cc71-3388-516c-99d2-a041c8f32f66'), CONVERT(uniqueidentifier, 'c3a49d43-a07c-5ccd-850e-d110a225d2ab'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P033/S091 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, '9d0b6c0b-2fd0-5260-91b8-4881aa43c390'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, '9d0b6c0b-2fd0-5260-91b8-4881aa43c390') AND id <> CONVERT(uniqueidentifier, '9d3fa7ea-9a8e-57b9-9a53-8116cd07a65f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P033/S091.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 600.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, '9d0b6c0b-2fd0-5260-91b8-4881aa43c390');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9d3fa7ea-9a8e-57b9-9a53-8116cd07a65f'), CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f'), CONVERT(uniqueidentifier, '9d0b6c0b-2fd0-5260-91b8-4881aa43c390'), 600.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P033/S092 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, 'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, 'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a') AND id <> CONVERT(uniqueidentifier, '2968e3f6-fedc-58bf-8cec-2fd87be34069'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P033/S092.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 50.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, 'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '2968e3f6-fedc-58bf-8cec-2fd87be34069'), CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f'), CONVERT(uniqueidentifier, 'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a'), 50.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P033/S093 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, '9098892b-5348-5fa5-9969-e5fb8913fe3f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, '9098892b-5348-5fa5-9969-e5fb8913fe3f') AND id <> CONVERT(uniqueidentifier, 'fdf777bf-dfdf-5b7f-a448-77d0e8673b95'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P033/S093.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f') AND service_id = CONVERT(uniqueidentifier, '9098892b-5348-5fa5-9969-e5fb8913fe3f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'fdf777bf-dfdf-5b7f-a448-77d0e8673b95'), CONVERT(uniqueidentifier, 'e587789f-2fcb-5ea5-be3d-9945c6e7c77f'), CONVERT(uniqueidentifier, '9098892b-5348-5fa5-9969-e5fb8913fe3f'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P034/S094 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2') AND id <> CONVERT(uniqueidentifier, '38dcc40d-cf48-5c5a-ad0a-ff7841e9129c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P034/S094.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 800.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '38dcc40d-cf48-5c5a-ad0a-ff7841e9129c'), CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631'), CONVERT(uniqueidentifier, '0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2'), 800.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P034/S095 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '71db8c41-d5a2-5df5-ab2d-444cb07bd73f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '71db8c41-d5a2-5df5-ab2d-444cb07bd73f') AND id <> CONVERT(uniqueidentifier, '51a0963c-eb7d-5c3e-b808-82a071afbcc3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P034/S095.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 50.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '71db8c41-d5a2-5df5-ab2d-444cb07bd73f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '51a0963c-eb7d-5c3e-b808-82a071afbcc3'), CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631'), CONVERT(uniqueidentifier, '71db8c41-d5a2-5df5-ab2d-444cb07bd73f'), 50.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P034/S096 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '96ce5b05-8c8d-5b10-b817-3e625456f458'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '96ce5b05-8c8d-5b10-b817-3e625456f458') AND id <> CONVERT(uniqueidentifier, 'd92334bf-57e8-59e1-afb6-5f1816855444'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P034/S096.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631') AND service_id = CONVERT(uniqueidentifier, '96ce5b05-8c8d-5b10-b817-3e625456f458');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd92334bf-57e8-59e1-afb6-5f1816855444'), CONVERT(uniqueidentifier, '2f018c73-2a40-544c-9df5-62e7d8d5d631'), CONVERT(uniqueidentifier, '96ce5b05-8c8d-5b10-b817-3e625456f458'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P035/S097 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71') AND service_id = CONVERT(uniqueidentifier, '0e691bb2-79b5-5385-9d67-14d4ba810e8f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71') AND service_id = CONVERT(uniqueidentifier, '0e691bb2-79b5-5385-9d67-14d4ba810e8f') AND id <> CONVERT(uniqueidentifier, '96fe4fc0-341c-5691-b90e-979b4da8062c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P035/S097.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 1000.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71') AND service_id = CONVERT(uniqueidentifier, '0e691bb2-79b5-5385-9d67-14d4ba810e8f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '96fe4fc0-341c-5691-b90e-979b4da8062c'), CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71'), CONVERT(uniqueidentifier, '0e691bb2-79b5-5385-9d67-14d4ba810e8f'), 1000.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P035/S040 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71') AND service_id = CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71') AND service_id = CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c') AND id <> CONVERT(uniqueidentifier, 'bdf7bb3e-7331-5cb2-b5a0-e10061e1f352'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P035/S040.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71') AND service_id = CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'bdf7bb3e-7331-5cb2-b5a0-e10061e1f352'), CONVERT(uniqueidentifier, '86e4f452-370b-55fb-9298-6d0dccfe1f71'), CONVERT(uniqueidentifier, 'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P036/S098 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29') AND id <> CONVERT(uniqueidentifier, '8b0f8221-e7e2-5493-9c16-76d027a8fe58'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P036/S098.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 400.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8b0f8221-e7e2-5493-9c16-76d027a8fe58'), CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d'), CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29'), 400.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P036/S099 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71') AND id <> CONVERT(uniqueidentifier, 'a105a0fc-11ec-5fd3-9a0d-4cfb6f1265b9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P036/S099.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 60.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'a105a0fc-11ec-5fd3-9a0d-4cfb6f1265b9'), CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d'), CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71'), 60.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P036/S100 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac') AND id <> CONVERT(uniqueidentifier, '2f2e1c66-591e-5e83-a1ee-53731a208bf3'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P036/S100.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d') AND service_id = CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '2f2e1c66-591e-5e83-a1ee-53731a208bf3'), CONVERT(uniqueidentifier, '6bc42dc3-4e64-599a-b557-6ada5fc1964d'), CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P037/S098 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29') AND id <> CONVERT(uniqueidentifier, 'a9118846-5e4a-5633-9b5e-4dd355e4d12a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P037/S098.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 500.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'a9118846-5e4a-5633-9b5e-4dd355e4d12a'), CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a'), CONVERT(uniqueidentifier, 'a02569be-0382-55f0-83de-1439793a7c29'), 500.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P037/S099 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71') AND id <> CONVERT(uniqueidentifier, 'b3621add-b76e-50dc-8019-8ca51813cf31'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P037/S099.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 60.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'b3621add-b76e-50dc-8019-8ca51813cf31'), CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a'), CONVERT(uniqueidentifier, 'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71'), 60.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P037/S100 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac') AND id <> CONVERT(uniqueidentifier, '6ddfe1d0-2253-5619-af3a-d1d2c2b0dd17'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P037/S100.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a') AND service_id = CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6ddfe1d0-2253-5619-af3a-d1d2c2b0dd17'), CONVERT(uniqueidentifier, 'f3e27495-c092-5c8e-acbd-edc469486a9a'), CONVERT(uniqueidentifier, '6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P038/S101 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587') AND id <> CONVERT(uniqueidentifier, '26b01055-338b-55dc-bb45-0648198ed0ec'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P038/S101.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '26b01055-338b-55dc-bb45-0648198ed0ec'), CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042'), CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587'), 350.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P038/S102 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, 'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, 'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae') AND id <> CONVERT(uniqueidentifier, 'f5c50751-e735-5942-b9c2-4245a76150bb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P038/S102.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, 'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'f5c50751-e735-5942-b9c2-4245a76150bb'), CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042'), CONVERT(uniqueidentifier, 'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae'), 150.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P038/S103 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814') AND id <> CONVERT(uniqueidentifier, '6b958d0f-6ebd-545a-b4e3-6f5ca6d57870'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P038/S103.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 130.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042') AND service_id = CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '6b958d0f-6ebd-545a-b4e3-6f5ca6d57870'), CONVERT(uniqueidentifier, 'f91c4081-8ec4-5fe1-b255-e92490c94042'), CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814'), 130.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P039/S101 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82') AND service_id = CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82') AND service_id = CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587') AND id <> CONVERT(uniqueidentifier, '687d757c-a4fc-52f5-9f1f-20a799de6f6e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P039/S101.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 350.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82') AND service_id = CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '687d757c-a4fc-52f5-9f1f-20a799de6f6e'), CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82'), CONVERT(uniqueidentifier, 'b5db10e5-8082-5274-aa13-4cf8a8dd9587'), 350.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Kapsam dışında P039/S102: Boncuklu/taşlı/güpürlü yatak örtüsünde hassas işlem farkı çift ücret oluşturabilir.

UPDATE pts
SET is_active = 0, is_default_selected = 0, update_date = SYSUTCDATETIME()
FROM [catalog].[product_type_services] pts
JOIN [catalog].[product_types] pt ON pt.id = pts.product_type_id
JOIN [catalog].[services] s ON s.id = pts.service_id
WHERE pt.code = N'P039' AND s.code = N'S102';

-- Seed çifti P039/S103 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82') AND service_id = CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82') AND service_id = CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814') AND id <> CONVERT(uniqueidentifier, 'a304f7aa-5de9-50bb-878b-421a7d501b29'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P039/S103.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 130.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82') AND service_id = CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'a304f7aa-5de9-50bb-878b-421a7d501b29'), CONVERT(uniqueidentifier, '55ec4405-e01f-595a-982d-9ac592995e82'), CONVERT(uniqueidentifier, '1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814'), 130.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P040/S104 (M2, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, 'bb26b219-d0dd-5c5f-8882-432803cc5ed6'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, 'bb26b219-d0dd-5c5f-8882-432803cc5ed6') AND id <> CONVERT(uniqueidentifier, '9786a9fe-2951-5104-b456-8917b29a5951'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P040/S104.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'M2',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, 'bb26b219-d0dd-5c5f-8882-432803cc5ed6');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9786a9fe-2951-5104-b456-8917b29a5951'), CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac'), CONVERT(uniqueidentifier, 'bb26b219-d0dd-5c5f-8882-432803cc5ed6'), 150.00, 'TRY', N'M2', N'BASE', 0, 1);
END;

-- Seed çifti P040/S028 (M2, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd') AND id <> CONVERT(uniqueidentifier, '0f132f4a-64e8-517f-9353-5038f802493e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P040/S028.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'M2',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0f132f4a-64e8-517f-9353-5038f802493e'), CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac'), CONVERT(uniqueidentifier, 'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd'), 120.00, 'TRY', N'M2', N'ADD_ON', 0, 1);
END;

-- Seed çifti P040/S105 (M2, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, '3ad1db91-07bf-5ca0-b200-962c7d895da5'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, '3ad1db91-07bf-5ca0-b200-962c7d895da5') AND id <> CONVERT(uniqueidentifier, 'f3f57de4-525b-5046-8647-dd99f29418ff'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P040/S105.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'M2',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac') AND service_id = CONVERT(uniqueidentifier, '3ad1db91-07bf-5ca0-b200-962c7d895da5');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'f3f57de4-525b-5046-8647-dd99f29418ff'), CONVERT(uniqueidentifier, '05456f26-7664-52f6-a150-f685aa41efac'), CONVERT(uniqueidentifier, '3ad1db91-07bf-5ca0-b200-962c7d895da5'), 100.00, 'TRY', N'M2', N'ADD_ON', 0, 1);
END;

-- Seed çifti P041/S106 (M2, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356') AND service_id = CONVERT(uniqueidentifier, '59233147-975b-57f3-9f55-40bc4fe0ea45'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356') AND service_id = CONVERT(uniqueidentifier, '59233147-975b-57f3-9f55-40bc4fe0ea45') AND id <> CONVERT(uniqueidentifier, 'd56ae07a-fbec-5238-8965-827dcb51b80b'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P041/S106.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 220.00, currency = 'TRY', price_unit = N'M2',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356') AND service_id = CONVERT(uniqueidentifier, '59233147-975b-57f3-9f55-40bc4fe0ea45');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'd56ae07a-fbec-5238-8965-827dcb51b80b'), CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356'), CONVERT(uniqueidentifier, '59233147-975b-57f3-9f55-40bc4fe0ea45'), 220.00, 'TRY', N'M2', N'BASE', 0, 1);
END;

-- Seed çifti P041/S013 (M2, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356') AND service_id = CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356') AND service_id = CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4') AND id <> CONVERT(uniqueidentifier, '3da596d1-e66c-5694-ae4e-278aeda322f5'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P041/S013.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 140.00, currency = 'TRY', price_unit = N'M2',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356') AND service_id = CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '3da596d1-e66c-5694-ae4e-278aeda322f5'), CONVERT(uniqueidentifier, 'be08397e-dad9-5a0c-be21-2cb9f6d4b356'), CONVERT(uniqueidentifier, '99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4'), 140.00, 'TRY', N'M2', N'ADD_ON', 0, 1);
END;

-- Seed çifti P042/S107 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, '55488406-f554-5b15-a97d-938298d3d089'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, '55488406-f554-5b15-a97d-938298d3d089') AND id <> CONVERT(uniqueidentifier, '72115bb5-c3e6-5e39-94e7-adef265b09c9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P042/S107.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 160.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, '55488406-f554-5b15-a97d-938298d3d089');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '72115bb5-c3e6-5e39-94e7-adef265b09c9'), CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775'), CONVERT(uniqueidentifier, '55488406-f554-5b15-a97d-938298d3d089'), 160.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P042/S108 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, '648a9052-8cc6-53f6-99fd-86f778214537'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, '648a9052-8cc6-53f6-99fd-86f778214537') AND id <> CONVERT(uniqueidentifier, '7f9f3dee-87e0-5833-af04-c64df73b0f6e'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P042/S108.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, '648a9052-8cc6-53f6-99fd-86f778214537');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '7f9f3dee-87e0-5833-af04-c64df73b0f6e'), CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775'), CONVERT(uniqueidentifier, '648a9052-8cc6-53f6-99fd-86f778214537'), 80.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P042/S109 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, 'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, 'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee') AND id <> CONVERT(uniqueidentifier, '455ccf24-3d3c-5076-92e1-2b15a0a45225'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P042/S109.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775') AND service_id = CONVERT(uniqueidentifier, 'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '455ccf24-3d3c-5076-92e1-2b15a0a45225'), CONVERT(uniqueidentifier, '1f838898-6265-5489-8181-455d12842775'), CONVERT(uniqueidentifier, 'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee'), 80.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P043/S011 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65') AND id <> CONVERT(uniqueidentifier, '0631b3cb-0172-542a-a005-75b516b7184a'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P043/S011.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '0631b3cb-0172-542a-a005-75b516b7184a'), CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847'), CONVERT(uniqueidentifier, 'f5cb27d9-22ce-5284-9180-55432d42db65'), 100.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P043/S110 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'b562c556-aa7f-5b33-bf0a-44cc105b22e7'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'b562c556-aa7f-5b33-bf0a-44cc105b22e7') AND id <> CONVERT(uniqueidentifier, 'c602fe4d-5d1b-5c58-a83f-151c10a660fe'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P043/S110.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 150.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'b562c556-aa7f-5b33-bf0a-44cc105b22e7');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'c602fe4d-5d1b-5c58-a83f-151c10a660fe'), CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847'), CONVERT(uniqueidentifier, 'b562c556-aa7f-5b33-bf0a-44cc105b22e7'), 150.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P043/S019 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f') AND id <> CONVERT(uniqueidentifier, '8f5ec4ac-60cc-5d2e-acd6-ae442680414f'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P043/S019.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847') AND service_id = CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '8f5ec4ac-60cc-5d2e-acd6-ae442680414f'), CONVERT(uniqueidentifier, '2247c5d8-af02-50dc-9db3-7520b04a2847'), CONVERT(uniqueidentifier, 'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P044/S111 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e') AND service_id = CONVERT(uniqueidentifier, 'de213140-b4b5-5c00-8c74-bcdafa9bd2a7'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e') AND service_id = CONVERT(uniqueidentifier, 'de213140-b4b5-5c00-8c74-bcdafa9bd2a7') AND id <> CONVERT(uniqueidentifier, '065039d5-eb8d-5965-b25c-4213d0c5de07'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P044/S111.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e') AND service_id = CONVERT(uniqueidentifier, 'de213140-b4b5-5c00-8c74-bcdafa9bd2a7');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '065039d5-eb8d-5965-b25c-4213d0c5de07'), CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e'), CONVERT(uniqueidentifier, 'de213140-b4b5-5c00-8c74-bcdafa9bd2a7'), 300.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P044/S112 (PIECE, ALTERNATIVE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e') AND service_id = CONVERT(uniqueidentifier, 'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e') AND service_id = CONVERT(uniqueidentifier, 'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4') AND id <> CONVERT(uniqueidentifier, '9c57262e-92c0-5254-b10c-e5aced8fe3a9'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P044/S112.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 220.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ALTERNATIVE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e') AND service_id = CONVERT(uniqueidentifier, 'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '9c57262e-92c0-5254-b10c-e5aced8fe3a9'), CONVERT(uniqueidentifier, '1c8e660b-641f-56d4-bdc7-1ecbeb02a53e'), CONVERT(uniqueidentifier, 'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4'), 220.00, 'TRY', N'PIECE', N'ALTERNATIVE', 0, 1);
END;

-- Seed çifti P045/S113 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c') AND service_id = CONVERT(uniqueidentifier, '0bb1b195-0c64-5f7c-997d-63290a0dada5'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c') AND service_id = CONVERT(uniqueidentifier, '0bb1b195-0c64-5f7c-997d-63290a0dada5') AND id <> CONVERT(uniqueidentifier, '15eeec09-c5f1-55cb-97da-c66b2c0040a8'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P045/S113.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c') AND service_id = CONVERT(uniqueidentifier, '0bb1b195-0c64-5f7c-997d-63290a0dada5');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '15eeec09-c5f1-55cb-97da-c66b2c0040a8'), CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c'), CONVERT(uniqueidentifier, '0bb1b195-0c64-5f7c-997d-63290a0dada5'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P045/S114 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c') AND service_id = CONVERT(uniqueidentifier, 'bacfff04-af69-5bcd-ad84-f5c54a00d82b'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c') AND service_id = CONVERT(uniqueidentifier, 'bacfff04-af69-5bcd-ad84-f5c54a00d82b') AND id <> CONVERT(uniqueidentifier, '398ccccd-ac41-5963-8c75-1d9ef7f79371'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P045/S114.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c') AND service_id = CONVERT(uniqueidentifier, 'bacfff04-af69-5bcd-ad84-f5c54a00d82b');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '398ccccd-ac41-5963-8c75-1d9ef7f79371'), CONVERT(uniqueidentifier, 'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c'), CONVERT(uniqueidentifier, 'bacfff04-af69-5bcd-ad84-f5c54a00d82b'), 100.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P046/S115 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf') AND service_id = CONVERT(uniqueidentifier, '9cc533b2-48be-53e7-b6c9-ab21bdb2fd56'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf') AND service_id = CONVERT(uniqueidentifier, '9cc533b2-48be-53e7-b6c9-ab21bdb2fd56') AND id <> CONVERT(uniqueidentifier, '5ce2c3cf-15ac-5539-8e1a-0038ec4adf57'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P046/S115.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 100.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf') AND service_id = CONVERT(uniqueidentifier, '9cc533b2-48be-53e7-b6c9-ab21bdb2fd56');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '5ce2c3cf-15ac-5539-8e1a-0038ec4adf57'), CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf'), CONVERT(uniqueidentifier, '9cc533b2-48be-53e7-b6c9-ab21bdb2fd56'), 100.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P046/S116 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf') AND service_id = CONVERT(uniqueidentifier, '558de248-1ed3-5efe-8299-626498657fe9'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf') AND service_id = CONVERT(uniqueidentifier, '558de248-1ed3-5efe-8299-626498657fe9') AND id <> CONVERT(uniqueidentifier, '3e8b91bc-2354-5468-a0f3-e9d8437112b1'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P046/S116.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 50.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf') AND service_id = CONVERT(uniqueidentifier, '558de248-1ed3-5efe-8299-626498657fe9');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '3e8b91bc-2354-5468-a0f3-e9d8437112b1'), CONVERT(uniqueidentifier, '8c8d76e8-a75b-57ad-ac31-bc66f65c43bf'), CONVERT(uniqueidentifier, '558de248-1ed3-5efe-8299-626498657fe9'), 50.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P047/S117 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '70d9a8e5-fd50-55e9-8186-4bc411a2b163'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '70d9a8e5-fd50-55e9-8186-4bc411a2b163') AND id <> CONVERT(uniqueidentifier, 'e782627c-7ff6-5423-a5a1-9e28c9f0acfd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P047/S117.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 300.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '70d9a8e5-fd50-55e9-8186-4bc411a2b163');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'e782627c-7ff6-5423-a5a1-9e28c9f0acfd'), CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1'), CONVERT(uniqueidentifier, '70d9a8e5-fd50-55e9-8186-4bc411a2b163'), 300.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P047/S118 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '66897085-9f8f-5599-8a1e-3c72e7b92f73'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '66897085-9f8f-5599-8a1e-3c72e7b92f73') AND id <> CONVERT(uniqueidentifier, '998252d1-4aad-594f-a81f-f6c66221f7fb'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P047/S118.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 120.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '66897085-9f8f-5599-8a1e-3c72e7b92f73');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '998252d1-4aad-594f-a81f-f6c66221f7fb'), CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1'), CONVERT(uniqueidentifier, '66897085-9f8f-5599-8a1e-3c72e7b92f73'), 120.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P047/S119 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '63a1ffa2-6167-5ce9-94f4-6ff191af8431'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '63a1ffa2-6167-5ce9-94f4-6ff191af8431') AND id <> CONVERT(uniqueidentifier, '792364ff-7eeb-56b7-be97-92e8ae866dcd'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P047/S119.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 40.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1') AND service_id = CONVERT(uniqueidentifier, '63a1ffa2-6167-5ce9-94f4-6ff191af8431');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '792364ff-7eeb-56b7-be97-92e8ae866dcd'), CONVERT(uniqueidentifier, '6040f1aa-b59d-5481-b25f-08a9893ae7c1'), CONVERT(uniqueidentifier, '63a1ffa2-6167-5ce9-94f4-6ff191af8431'), 40.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

-- Seed çifti P048/S120 (PIECE, BASE)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17') AND service_id = CONVERT(uniqueidentifier, '2b823fe4-9cbf-543d-a0b1-8bc51b9db922'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17') AND service_id = CONVERT(uniqueidentifier, '2b823fe4-9cbf-543d-a0b1-8bc51b9db922') AND id <> CONVERT(uniqueidentifier, 'afc91a3c-c4bf-51bc-986b-0064ee0b843c'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P048/S120.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 200.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'BASE', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17') AND service_id = CONVERT(uniqueidentifier, '2b823fe4-9cbf-543d-a0b1-8bc51b9db922');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, 'afc91a3c-c4bf-51bc-986b-0064ee0b843c'), CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17'), CONVERT(uniqueidentifier, '2b823fe4-9cbf-543d-a0b1-8bc51b9db922'), 200.00, 'TRY', N'PIECE', N'BASE', 0, 1);
END;

-- Seed çifti P048/S121 (PIECE, ADD_ON)

IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17') AND service_id = CONVERT(uniqueidentifier, 'f7134bc3-cf91-5bac-872c-fe3285278016'))
BEGIN
    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17') AND service_id = CONVERT(uniqueidentifier, 'f7134bc3-cf91-5bac-872c-fe3285278016') AND id <> CONVERT(uniqueidentifier, '503347b6-03c8-51be-8c07-d5c66e50f7bf'))
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: P048/S121.', 1;
    UPDATE [catalog].[product_type_services]
    SET default_price = 80.00, currency = 'TRY', price_unit = N'PIECE',
        selection_kind = N'ADD_ON', is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    WHERE product_type_id = CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17') AND service_id = CONVERT(uniqueidentifier, 'f7134bc3-cf91-5bac-872c-fe3285278016');
END
ELSE
BEGIN
    INSERT [catalog].[product_type_services]
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    VALUES
        (CONVERT(uniqueidentifier, '503347b6-03c8-51be-8c07-d5c66e50f7bf'), CONVERT(uniqueidentifier, 'd8404e4d-9f49-585c-960f-67467a4f9a17'), CONVERT(uniqueidentifier, 'f7134bc3-cf91-5bac-872c-fe3285278016'), 80.00, 'TRY', N'PIECE', N'ADD_ON', 0, 1);
END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

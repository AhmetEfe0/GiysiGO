-- docs/generate-catalog-seed.mjs tarafından üretilmiştir. Bu dosyayı doğrudan düzenlemeyin.
-- Kimlikler sabit kaynak kodlarından türetilir; kapsam dışı veya karar bekleyen çiftler aktif sunulmaz.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Kaynak veriler: her kayıt tek satırdır; ilişkiler okunabilir kaynak kodlarıyla belirtilir.
DECLARE @SeedCategories TABLE (id uniqueidentifier NOT NULL, code nvarchar(100) PRIMARY KEY, name nvarchar(200) NOT NULL, sort_order int NOT NULL);
DECLARE @SeedProducts TABLE (id uniqueidentifier NOT NULL, code nvarchar(100) PRIMARY KEY, category_code nvarchar(100) NOT NULL, name nvarchar(200) NOT NULL, base_unit nvarchar(20) NOT NULL);
DECLARE @SeedServices TABLE (id uniqueidentifier NOT NULL, code nvarchar(100) PRIMARY KEY, name nvarchar(200) NOT NULL);
DECLARE @SeedPairs TABLE (id uniqueidentifier NOT NULL, product_code nvarchar(100) NOT NULL, service_code nvarchar(100) NOT NULL, default_price decimal(12,2) NOT NULL, price_unit nvarchar(20) NOT NULL, selection_kind nvarchar(30) NOT NULL, PRIMARY KEY (product_code, service_code));
DECLARE @ExcludedPairs TABLE (product_code nvarchar(100) NOT NULL, service_code nvarchar(100) NOT NULL, PRIMARY KEY (product_code, service_code));

INSERT @SeedCategories (id, code, name, sort_order) VALUES
    (N'77739beb-7693-5fc0-841c-bd5101aa18a3', N'DAILY', N'GÜNLÜK GİYİM', 0),
    (N'68cca443-1430-5ff4-8249-061e798b9138', N'OUTERWEAR', N'DIŞ GİYİM', 1),
    (N'8045e7bd-6bb5-5f9e-bf13-8a7fc2dd49d8', N'OCCASION', N'DAVET & ŞIK GİYİM', 2),
    (N'476242ee-b4c5-57ba-bdb7-ff744fff6727', N'HOME_TEXTILE', N'EV TEKSTİLİ', 3),
    (N'f8353a9f-0ff7-58a9-8e0a-6bce48da7729', N'ACCESSORIES', N'AKSESUAR & DİĞER', 4);

INSERT @SeedProducts (id, code, category_code, name, base_unit) VALUES
    (N'900fc4b2-7ee8-51b3-83e5-b804fd6b24f7', N'P001', N'DAILY', N'Gömlek', N'PIECE'),
    (N'c30dfa10-5873-56b9-b906-d2b95df57d8d', N'P002', N'DAILY', N'Bluz (Kumaş / İpek / Şifon)', N'PIECE'),
    (N'8e821699-a1d4-5042-b597-d85c5781f1fe', N'P003', N'DAILY', N'Tişört / Polo Yaka', N'PIECE'),
    (N'8cb54791-ee70-5f15-8eb4-83e2ba859e69', N'P004', N'DAILY', N'Kazak / Triko / Hırka / Süveter', N'PIECE'),
    (N'8f8296fd-9aca-53f0-afd1-9081a46d69c7', N'P005', N'DAILY', N'Sweatshirt / Hoodie', N'PIECE'),
    (N'b8fe853a-dd70-54dc-a2ae-835122b5a95f', N'P006', N'DAILY', N'Pantolon (Kumaş / Kot)', N'PIECE'),
    (N'5991b9c4-405f-594c-a9e2-67f1fbff0da1', N'P007', N'DAILY', N'Etek', N'PIECE'),
    (N'27d9a206-c352-5802-b92d-b75e58ad4705', N'P008', N'DAILY', N'Pileli Etek', N'PIECE'),
    (N'd3455b4f-8485-5040-b02f-ff5e4c4b73bd', N'P009', N'DAILY', N'Günlük Elbise', N'PIECE'),
    (N'5bc41168-949d-592e-8da3-598f7a30bcf3', N'P010', N'DAILY', N'Tulum / Salopet', N'PIECE'),
    (N'd9a7e88c-69ca-55da-a4c4-2b71c6d34174', N'P011', N'DAILY', N'Şort / Eşofman Altı', N'PIECE'),
    (N'4103433a-c429-54e0-98ec-88411a85e50c', N'P012', N'OUTERWEAR', N'Ceket / Blazer', N'PIECE'),
    (N'a360713d-4870-51bd-8c54-3b3fc55ce5fb', N'P013', N'OUTERWEAR', N'Kaban / Palto', N'PIECE'),
    (N'f789e5a8-dc1b-5000-95d6-822040c7ba39', N'P014', N'OUTERWEAR', N'Mont', N'PIECE'),
    (N'46830851-0a16-582e-b6d1-ba195ac1efa0', N'P015', N'OUTERWEAR', N'Kaz / Kuş Tüyü Mont (Kısa)', N'PIECE'),
    (N'8fcecc5d-16d0-58df-ba68-74c2c538af0d', N'P016', N'OUTERWEAR', N'Kaz / Kuş Tüyü Kaban / Palto (Uzun)', N'PIECE'),
    (N'618c3741-1d58-5495-bd54-1c395ff65a08', N'P017', N'OUTERWEAR', N'Kaz / Kuş Tüyü Yelek / Şişme Yelek', N'PIECE'),
    (N'7242fead-4555-5a9a-b3f7-572dc837987a', N'P018', N'OUTERWEAR', N'Trençkot / Pardösü', N'PIECE'),
    (N'6b9afd98-e8b8-5190-997b-4db61110ef68', N'P019', N'OUTERWEAR', N'Hakiki Deri Ceket / Mont', N'PIECE'),
    (N'b288daa9-0e3c-5ccd-9792-2e741bfcf2bd', N'P020', N'OUTERWEAR', N'Suni Deri Ceket / Mont', N'PIECE'),
    (N'6e8184f8-4874-536f-8a0c-3ac81e9b8f38', N'P021', N'OUTERWEAR', N'Süet Ceket / Mont', N'PIECE'),
    (N'65d09160-7a43-51d3-a033-8a2ac609d163', N'P022', N'OUTERWEAR', N'Kürk (Hakiki)', N'PIECE'),
    (N'3cd13fdf-8cf3-54c6-a0b8-221bcdda8680', N'P023', N'OUTERWEAR', N'Kürk (Suni)', N'PIECE'),
    (N'774b715d-57f9-5847-ab16-3b18e739adc0', N'P024', N'OUTERWEAR', N'Motorcu Montu', N'PIECE'),
    (N'bcefdefb-46dd-53b9-8b69-fb0434698f14', N'P025', N'OCCASION', N'Takım Elbise (2 Parça)', N'PIECE'),
    (N'6856b51b-29aa-5583-922e-f9e0538fde36', N'P026', N'OCCASION', N'Yelekli Takım Elbise (3 Parça)', N'PIECE'),
    (N'b37b866b-d0ce-53dd-b1b9-1c7f25694e2a', N'P027', N'OCCASION', N'Abiye / Gece Elbisesi (Sade / Düz)', N'PIECE'),
    (N'50055790-3ee1-5d51-b802-b4998fdb9a38', N'P028', N'OCCASION', N'Abiye / Gece Elbisesi (Taşlı / Pullu / Şifon)', N'PIECE'),
    (N'35c1190a-69aa-5d57-859a-dbd21f98e068', N'P029', N'OCCASION', N'Gelinlik (Sade / Düz)', N'PIECE'),
    (N'57e92e2a-488b-5814-8896-c6fc64380156', N'P030', N'OCCASION', N'Gelinlik (İşlemeli / Taşlı / Kuyruklu)', N'PIECE'),
    (N'420cad67-4fe1-57a6-b066-c9a00f3ceb69', N'P031', N'OCCASION', N'Nişanlık / Kınalık / Kaftan', N'PIECE'),
    (N'ec56cc71-3388-516c-99d2-a041c8f32f66', N'P032', N'OCCASION', N'Duvak', N'PIECE'),
    (N'e587789f-2fcb-5ea5-be3d-9945c6e7c77f', N'P033', N'HOME_TEXTILE', N'Elyaf Yorgan (Tek / Çift Kişilik)', N'PIECE'),
    (N'2f018c73-2a40-544c-9df5-62e7d8d5d631', N'P034', N'HOME_TEXTILE', N'Yün / Pamuk Yorgan', N'PIECE'),
    (N'86e4f452-370b-55fb-9298-6d0dccfe1f71', N'P035', N'HOME_TEXTILE', N'Kaz Tüyü Yorgan', N'PIECE'),
    (N'6bc42dc3-4e64-599a-b557-6ada5fc1964d', N'P036', N'HOME_TEXTILE', N'Battaniye', N'PIECE'),
    (N'f3e27495-c092-5c8e-acbd-edc469486a9a', N'P037', N'HOME_TEXTILE', N'Battaniye (Büyük Boy)', N'PIECE'),
    (N'f91c4081-8ec4-5fe1-b255-e92490c94042', N'P038', N'HOME_TEXTILE', N'Yatak Örtüsü (Sade)', N'PIECE'),
    (N'55ec4405-e01f-595a-982d-9ac592995e82', N'P039', N'HOME_TEXTILE', N'Yatak Örtüsü (Boncuklu/Taşlı/Güpürlü)', N'PIECE'),
    (N'05456f26-7664-52f6-a150-f685aa41efac', N'P040', N'HOME_TEXTILE', N'Tül Perde (m2)', N'M2'),
    (N'be08397e-dad9-5a0c-be21-2cb9f6d4b356', N'P041', N'HOME_TEXTILE', N'Fon Perde (m2)', N'M2'),
    (N'1f838898-6265-5489-8181-455d12842775', N'P042', N'HOME_TEXTILE', N'Masa Örtüsü', N'PIECE'),
    (N'2247c5d8-af02-50dc-9db3-7520b04a2847', N'P043', N'HOME_TEXTILE', N'Koltuk / Kırlent Kılıfı', N'PIECE'),
    (N'1c8e660b-641f-56d4-bdc7-1ecbeb02a53e', N'P044', N'HOME_TEXTILE', N'Yastık (Elyaf / Tüy)', N'PIECE'),
    (N'e4575c3e-93c2-5b4e-9b1b-f6dda961fa9c', N'P045', N'ACCESSORIES', N'Eşarp / Şal / Fular', N'PIECE'),
    (N'8c8d76e8-a75b-57ad-ac31-bc66f65c43bf', N'P046', N'ACCESSORIES', N'Kravat / Papyon', N'PIECE'),
    (N'6040f1aa-b59d-5481-b25f-08a9893ae7c1', N'P047', N'ACCESSORIES', N'Bez / Kumaş Spor Ayakkabı (Sneaker)', N'PIECE'),
    (N'd8404e4d-9f49-585c-960f-67467a4f9a17', N'P048', N'ACCESSORIES', N'Kasket / Şapka', N'PIECE');

INSERT @SeedServices (id, code, name) VALUES
    (N'7077bbc5-6f21-525a-abc2-d296fffd0f96', N'S001', N'Kuru Temizleme & Ütü (Standart)'),
    (N'd59ffd8d-b69d-503b-8350-83e1f2265ab5', N'S002', N'Sadece Ütü (Temizleme Hariç)'),
    (N'eade1c05-2663-50ee-91c2-8f6de0cbb62a', N'S003', N'Kol Kısaltma (Manşetli Tadilat)'),
    (N'45741922-b1f4-51ab-9ad6-021648ce9cde', N'S004', N'Beden Daraltma (Pens)'),
    (N'394cbae8-a2e2-5690-be8f-9ee6b787d7aa', N'S005', N'Düğme Dikimi / Onarımı'),
    (N'445ea14b-4dd2-5d3d-9c57-18e5897af9c4', N'S006', N'Hassas Kuru Temizleme & Ütü'),
    (N'69517098-d314-5143-9724-cf6ec7c852c9', N'S007', N'Sadece Buharlı Form Ütü'),
    (N'c767508a-27b8-5af3-bb8f-e7851e6b2c20', N'S008', N'Askı / Kol Boyu Kısaltma'),
    (N'8648a6fb-443f-5362-9737-4df86858a328', N'S009', N'Beden Daraltma'),
    (N'29dd94b4-5cdb-5454-84ca-549c0d6c2e31', N'S010', N'Dikiş / Sökük Onarımı'),
    (N'f5cb27d9-22ce-5284-9180-55432d42db65', N'S011', N'Yıkama & Ütü'),
    (N'736832a0-af56-5bab-9775-455640add053', N'S012', N'Sadece Ütü'),
    (N'99aeb7cf-7ee5-53d8-8fd1-87ed04e605d4', N'S013', N'Boy Kısaltma'),
    (N'cd4fe896-319e-5f06-bcc2-1e81de28563a', N'S014', N'Yaka / Dikiş Onarımı'),
    (N'c564833d-7170-53ce-9d69-5b46db110362', N'S015', N'Yün Kuru Temizleme & Form Pres'),
    (N'0ff86b2c-49e3-56ca-bbca-0c01e24a49dd', N'S016', N'Tiftik / Hav Alma Bakımı'),
    (N'da9a789f-fd95-57d1-aba5-2e0759cd92dd', N'S017', N'İlmek / Kaçık Örme (Delik Tamiri)'),
    (N'611ba769-e2bf-50db-bc3c-060a0db139c8', N'S018', N'Kol Boyu Kısaltma'),
    (N'bf26f87d-38b2-51d5-97b3-3c4f157d1a7f', N'S019', N'Fermuar Değişimi'),
    (N'21db9ce1-27c3-524b-9af2-4e777105e4e3', N'S020', N'Manşet / Cep Dikişi'),
    (N'ad7b5cd4-352d-5856-b971-7d7a947b607e', N'S021', N'Kuru Temizleme & Çift Çizgi Pres Ütü'),
    (N'c6418fae-c610-52c4-a0e0-1a254dedcc1a', N'S022', N'Sadece Pres Ütü'),
    (N'7c3aa8c9-e1d0-5754-8679-5389db6d82c4', N'S023', N'Düz Paça Kısaltma'),
    (N'ba164588-634a-5c2c-b594-7c2a5fe848f1', N'S024', N'Duble Paça Yapımı'),
    (N'5e76ef7b-fe42-5d22-b0a7-829d1f1e0326', N'S025', N'Bel Daraltma / Genişletme'),
    (N'261c8fc7-08a3-5993-bf4a-476b03c870ab', N'S026', N'Basen / Paça Daraltma'),
    (N'd8aa6e63-2a06-5f36-9934-fda929c05fba', N'S027', N'Kuru Temizleme & Ütü'),
    (N'b30ae6f3-a24a-525a-a05a-fbdf3d3064dd', N'S028', N'Etek Boyu Kısaltma'),
    (N'0a6a5b3b-77f4-5a17-9d26-bd5ffbc77dd1', N'S029', N'Bel Daraltma'),
    (N'cdb16ee9-234b-5d20-9138-d8a08a5cb20c', N'S030', N'Gizli Fermuar Değişimi'),
    (N'2eb0a9e3-1809-5092-8652-9545002af4be', N'S031', N'Kuru Temizleme & Pile Presi'),
    (N'b2984dc4-904c-504a-a51e-0d65997b7069', N'S032', N'Sadece Pile Form Presi'),
    (N'094bbf6a-c8ae-5fc7-80e0-79bd202bb395', N'S033', N'Bel Tadilatı'),
    (N'bc5d02e7-dfd8-5c67-8125-f999011fc820', N'S034', N'Paça Kısaltma'),
    (N'699a66f6-56ed-5c05-bdfb-f3bcbf79f00a', N'S035', N'Askı / Beden Ayarı'),
    (N'5f4258af-012d-577e-a7ea-c9b3a506dbdc', N'S036', N'Bel Lastiği / Kordon Değişimi'),
    (N'563006fb-e70f-51df-b266-64822f63ad02', N'S037', N'Kuru Temizleme & Form Pres Ütü'),
    (N'0b15470c-8116-55e4-bc3a-e407ff91cd7b', N'S038', N'Kol Kısaltma (Düz)'),
    (N'59590b50-617b-55e2-86bf-01abf06e0a87', N'S039', N'Kol Kısaltma (Düğmeli)'),
    (N'dd1a30e1-1c48-5ebe-9064-1f1575b2a02c', N'S040', N'Astar Söküğü Tamiri'),
    (N'41d37138-5011-5fbf-8fe9-0f45ec14cf2f', N'S041', N'Kuru Temizleme & Form Pres'),
    (N'b1f37ddc-c005-5556-a0c5-ac806978f0bc', N'S042', N'Sadece Form Pres Ütü'),
    (N'0e695b64-2889-5fe3-b6a4-aa680d63363b', N'S043', N'Kol Kısaltma'),
    (N'8e73dff7-96f2-5030-901c-ec53f30e2ae2', N'S044', N'Astar Değişimi / Onarımı'),
    (N'8c0c364f-7732-5cde-97cd-4c69fefd032d', N'S045', N'Düğme / Çıtçıt Dikimi'),
    (N'66c63af4-1a42-5ac4-aa2b-05c210686f8d', N'S046', N'Kemik Fermuar Değişimi'),
    (N'c070a9c1-cce2-519a-9e15-441e5210c83d', N'S047', N'Yırtık / Kumaş Yaması'),
    (N'609afdd2-772e-5541-bc6c-96be9f041aae', N'S048', N'Özel Kuru Temizleme & Tüy Kabartma'),
    (N'6650cb67-716b-549e-ac5a-bd7897c7513f', N'S049', N'Yırtık / Dikiş Onarımı'),
    (N'9c397969-7be5-5df2-a4e0-48039b8c24aa', N'S050', N'Uzun Temizleme & Tüy Kabartma Presi'),
    (N'1424f776-c630-5a22-9a85-e6987d2ffc0c', N'S051', N'Çift Yönlü Uzun Fermuar Değişimi'),
    (N'05aeb3f9-f2f6-56e7-9292-e4e26bce0715', N'S052', N'Temizleme & Kabartma Bakımı'),
    (N'176e4cf8-e704-596b-aa28-018b698dc755', N'S053', N'Kuru Temizleme & Form Ütüsü'),
    (N'4ad2db46-3f0b-5d90-ae82-93ff1fb94172', N'S054', N'Su İtici Koruyucu Bakım'),
    (N'1219e2ed-0953-5ef7-864c-4a9899337f46', N'S055', N'Kol / Boy Kısaltma'),
    (N'3ad4f605-fe02-5bd0-b07f-e9f774dafc0a', N'S056', N'Kemer / Toka Tamiri'),
    (N'2e77d708-5fa6-54d1-bc4e-3bafbc0546bf', N'S057', N'Özel Deri Temizleme & Besleme Yağlaması'),
    (N'6418be14-d7d7-5f1d-8529-05290fc827ce', N'S058', N'Deri Boyama & Renk Yenileme'),
    (N'30fa771e-8552-5625-81b0-77204a320daa', N'S059', N'Deri Fermuar Değişimi'),
    (N'0fdcfbe7-1292-590c-aa48-0ad68e140f72', N'S060', N'Deri Kol Kısaltma'),
    (N'8f54536c-31b1-51c7-acdd-810dc8d9e32a', N'S061', N'Hassas Nemli Temizleme'),
    (N'8e95dbd7-a01e-5dfd-96e1-cf3c6fb838e8', N'S062', N'Süet Temizleme & Doku Canlandırma'),
    (N'f8c3584c-7f2c-5d69-98eb-35866aac0b1a', N'S063', N'Fermuar / Düğme Onarımı'),
    (N'ed26886f-ddc7-536e-b0da-6a0eef1f4ba1', N'S064', N'Hassas Kürk Temizleme & Havlandırma'),
    (N'f477e9f3-0a9e-5279-b55f-c9c3b1b1c6eb', N'S065', N'Klips / Kopça Onarımı'),
    (N'1bc7b0c8-6d92-5ec6-996e-8e75fcb0f8ee', N'S066', N'Astar Onarımı'),
    (N'ed75dc26-1195-575d-9449-a9f24130bed4', N'S067', N'Koruma Sökümlü Derin Temizleme & Dezenfeksiyon'),
    (N'e495909b-79af-5e80-a006-84d850bda911', N'S068', N'Ağır Hizmet Fermuar Değişimi'),
    (N'81732f9b-beec-540e-aafe-4bd8a8d63119', N'S069', N'Kuru Temizleme & Çift Pres Ütü'),
    (N'f067cbfb-660a-5f13-b80e-64ec0997ecfe', N'S070', N'Pantolon Paça Kısaltma'),
    (N'9d88b3d2-f617-54a0-9c4d-740f4c3ed946', N'S071', N'Pantolon Bel Daraltma'),
    (N'a04acb35-29d5-5bfd-96a6-c501670049f2', N'S072', N'Ceket Kol Kısaltma'),
    (N'35d552ba-dccb-54a4-b722-5ad9b91495e1', N'S073', N'Kuru Temizleme & Komple Pres'),
    (N'f6060f16-0ff7-5cd5-879b-01e4f22b3f28', N'S074', N'Komple Beden Ölçü Provası'),
    (N'1ee68bf0-8fc4-5769-9278-178b31f83abf', N'S075', N'Hassas Kuru Temizleme & Buhar Ütü'),
    (N'ad8a7f6a-26f2-5cd2-a1e3-18fbfb724d69', N'S076', N'Sadece Askı Buhar Ütüsü'),
    (N'9e6cb8ea-367a-5df5-a378-56981029751a', N'S077', N'Beden / Göğüs Daraltma'),
    (N'd829249a-8913-5eb7-8784-f08b4dfb3214', N'S078', N'Askı Boyu Ayarlama'),
    (N'37f584ca-3203-5713-81c4-6d0c81e00c3e', N'S079', N'Korumalı Hassas Temizleme & Buhar'),
    (N'7742e586-122d-5cd4-b414-196fc5c3f513', N'S080', N'Katmanlı Tül Boy Kısaltma'),
    (N'fa93fb50-bd3c-5cba-8690-7a2cb5161c68', N'S081', N'Düşen Taş / Pul Onarımı'),
    (N'5cd4a254-ddb8-5897-bbb1-6a4eee015437', N'S082', N'Detaylı Temizleme & Buhar Pres'),
    (N'6dd2172b-2fb3-58a4-a1af-6d3c0f0c8671', N'S083', N'Boy Kısaltma / Beden Ayarı'),
    (N'cf76c324-dc08-581a-a9c6-7c72de3be743', N'S084', N'Özel Havuz Leke Temizliği & Askı Presi'),
    (N'e802bbab-75a6-5df3-aa8b-6e905bee20c6', N'S085', N'Tül Yırtığı Tamiri'),
    (N'c17bfb3a-7d4c-5d5b-9a8e-15d74458c07a', N'S086', N'Kuyruk / Korse Tadilatı'),
    (N'1e2e5bab-8745-5351-8652-601e4fe2d4a2', N'S087', N'Hassas İşlemeli Kumaş Temizleme & Ütü'),
    (N'c5be23d3-24d2-5e8e-8e5f-1e02ef81fb70', N'S088', N'Sırma / Pul / Sim Onarımı'),
    (N'0dea4e35-e64a-5b4e-bde7-23e73d7d3262', N'S089', N'Hassas Temizleme & Buhar'),
    (N'c3a49d43-a07c-5ccd-850e-d110a225d2ab', N'S090', N'Toka / Tarak Sabitleme'),
    (N'9d0b6c0b-2fd0-5260-91b8-4881aa43c390', N'S091', N'Sanayi Tipi Hijyenik Yıkama & Kurutma'),
    (N'dfd6fc6f-f79d-5f98-98ad-6ba9d616512a', N'S092', N'Büyük Boy / Battal Ebat Farkı'),
    (N'9098892b-5348-5fa5-9969-e5fb8913fe3f', N'S093', N'Yırtık / Sökük Dikişi'),
    (N'0c4f54ba-2ddb-5d6a-b45d-4de9714bc0d2', N'S094', N'Özel Dolgu Koruma Yıkama & Hav Kurutma'),
    (N'71db8c41-d5a2-5df5-ab2d-444cb07bd73f', N'S095', N'Çift Kişilik Ebat Farkı'),
    (N'96ce5b05-8c8d-5b10-b817-3e625456f458', N'S096', N'Kenar Dikiş Onarımı'),
    (N'0e691bb2-79b5-5385-9d67-14d4ba810e8f', N'S097', N'Kaz Tüyü Açıcı Yıkama & Kabartma Kurutması'),
    (N'a02569be-0382-55f0-83de-1439793a7c29', N'S098', N'Yumuşatıcı Yıkama & Kurutma'),
    (N'aaf842dd-fb4a-5c21-a2b6-cf8db7faef71', N'S099', N'Büyük Boy / Pelüş Farkı'),
    (N'6ccdc9f3-93a1-5a4c-84e1-80898d1a57ac', N'S100', N'Kenar Overlok Dikişi'),
    (N'b5db10e5-8082-5274-aa13-4cf8a8dd9587', N'S101', N'Yıkama & Pres Ütü'),
    (N'b1c55e10-ccc5-5eee-8db1-b8100d9c9fae', N'S102', N'Taşlı / Güpürlü Hassas İşlem Farkı'),
    (N'1fcc57f9-8cf0-5835-bd5b-c7cdcf9e4814', N'S103', N'Saçak / Dikiş Tamiri'),
    (N'bb26b219-d0dd-5c5f-8882-432803cc5ed6', N'S104', N'Yıkama & Buharlı Kırışıklık Açma'),
    (N'3ad1db91-07bf-5ca0-b200-962c7d895da5', N'S105', N'Rulet / Ekstrafor Dikimi'),
    (N'59233147-975b-57f3-9f55-40bc4fe0ea45', N'S106', N'Kuru Temizleme & Form Presi'),
    (N'55488406-f554-5b15-a97d-938298d3d089', N'S107', N'Leke Çıkarma Banyosu & Kolalı Pres'),
    (N'648a9052-8cc6-53f6-99fd-86f778214537', N'S108', N'Sadece Kolalı Pres Ütü'),
    (N'b9fd65fd-f1e1-58b5-8d95-f4c3bfdc03ee', N'S109', N'Köşe Dikiş Tamiri'),
    (N'b562c556-aa7f-5b33-bf0a-44cc105b22e7', N'S110', N'Kuru Temizleme'),
    (N'de213140-b4b5-5c00-8c74-bcdafa9bd2a7', N'S111', N'Elyaf Yıkama & Dezenfeksiyon'),
    (N'e5e47cf0-6d1d-5259-8bf9-ec6eecd4dfd4', N'S112', N'Yün / Kaz Tüyü Özel Yıkama'),
    (N'0bb1b195-0c64-5f7c-997d-63290a0dada5', N'S113', N'İpek Kuru Temizleme & Buhar'),
    (N'bacfff04-af69-5bcd-ad84-f5c54a00d82b', N'S114', N'Kenar Dikişi'),
    (N'9cc533b2-48be-53e7-b6c9-ab21bdb2fd56', N'S115', N'Kuru Temizleme & Pres'),
    (N'558de248-1ed3-5efe-8299-626498657fe9', N'S116', N'Arka Dikiş Onarımı'),
    (N'70d9a8e5-fd50-55e9-8186-4bc411a2b163', N'S117', N'Manuel Köpüklü Yıkama & Ozon'),
    (N'66897085-9f8f-5599-8a1e-3c72e7b92f73', N'S118', N'Taban Yapıştırma'),
    (N'63a1ffa2-6167-5ce9-94f4-6ff191af8431', N'S119', N'Bağcık Yenileme'),
    (N'2b823fe4-9cbf-543d-a0b1-8bc51b9db922', N'S120', N'Kalıp Form Kuru Temizleme'),
    (N'f7134bc3-cf91-5bac-872c-fe3285278016', N'S121', N'İç Bant / Dikiş Onarımı');

INSERT @SeedPairs (id, product_code, service_code, default_price, price_unit, selection_kind) VALUES
    (N'87da03a6-d4c5-5c59-9908-7b1b5daa2d56', N'P001', N'S001', 200.00, N'PIECE', N'BASE'), -- Seed çifti P001/S001 (PIECE, BASE)
    (N'e1194455-1b0d-5fa2-aaae-265ee0190caa', N'P001', N'S002', 100.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P001/S002 (PIECE, ALTERNATIVE)
    (N'7f4a2fcc-a66a-55f9-a6d6-5caf3b0a5708', N'P001', N'S003', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P001/S003 (PIECE, ADD_ON; terzi kalemi 10)
    (N'f6f83602-eb0d-55c7-9535-f35646848761', N'P001', N'S004', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P001/S004 (PIECE, ADD_ON; terzi kalemi 12)
    (N'e14b5be3-f7d6-5d0c-97fc-eccad1a44d54', N'P001', N'S005', 30.00, N'PIECE', N'ADD_ON'), -- Seed çifti P001/S005 (PIECE, ADD_ON; terzi kalemi 16)
    (N'a8e95908-286d-5282-8450-20d8a197d063', N'P002', N'S006', 200.00, N'PIECE', N'BASE'), -- Seed çifti P002/S006 (PIECE, BASE)
    (N'e3930efe-aae6-53f1-aeab-c893d59f0fd4', N'P002', N'S007', 80.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P002/S007 (PIECE, ALTERNATIVE)
    (N'0675027a-15bc-56fa-8cfa-0c40cd745a67', N'P002', N'S008', 130.00, N'PIECE', N'ADD_ON'), -- Seed çifti P002/S008 (PIECE, ADD_ON)
    (N'525c04dc-4101-51b2-a537-16f05d26124e', N'P002', N'S009', 140.00, N'PIECE', N'ADD_ON'), -- Seed çifti P002/S009 (PIECE, ADD_ON; terzi kalemi 12)
    (N'dd297916-808a-5fdc-a8d9-9cba76cd87b1', N'P002', N'S010', 70.00, N'PIECE', N'ADD_ON'), -- Seed çifti P002/S010 (PIECE, ADD_ON; terzi kalemi 15)
    (N'29ff18f4-262a-5f97-843d-c9ad3479903e', N'P003', N'S011', 200.00, N'PIECE', N'BASE'), -- Seed çifti P003/S011 (PIECE, BASE)
    (N'04d7ca6e-fd78-5bbf-a752-e08d4520888f', N'P003', N'S012', 80.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P003/S012 (PIECE, ALTERNATIVE)
    (N'd9ce33b7-77d4-56a9-a09e-5e8c13b2c41f', N'P003', N'S013', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P003/S013 (PIECE, ADD_ON)
    (N'e9282ea1-ac97-58e7-a7fd-2a431f2809e6', N'P003', N'S014', 60.00, N'PIECE', N'ADD_ON'), -- Seed çifti P003/S014 (PIECE, ADD_ON; terzi kalemi 15)
    (N'd8483b54-61b0-581c-8763-4b1f439d3cb7', N'P004', N'S015', 200.00, N'PIECE', N'BASE'), -- Seed çifti P004/S015 (PIECE, BASE)
    (N'50afd079-eb07-5cb7-91de-2e7f688d5a49', N'P004', N'S016', 80.00, N'PIECE', N'ADD_ON'), -- Seed çifti P004/S016 (PIECE, ADD_ON)
    (N'917b980c-8895-56c1-9050-b2dc3c5b4ad7', N'P004', N'S017', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P004/S017 (PIECE, ADD_ON)
    (N'9ae979af-f5b6-5179-ad67-0b8ed26e992a', N'P004', N'S018', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P004/S018 (PIECE, ADD_ON)
    (N'50f70561-f80a-5c0f-aa2f-09a0436ba7ce', N'P005', N'S011', 250.00, N'PIECE', N'BASE'), -- Seed çifti P005/S011 (PIECE, BASE)
    (N'e7a74e90-b40c-5414-8618-ad2df72b5bea', N'P005', N'S019', 180.00, N'PIECE', N'ADD_ON'), -- Seed çifti P005/S019 (PIECE, ADD_ON)
    (N'bfc7efd1-8515-564b-bc93-0550ec1d42b8', N'P005', N'S020', 70.00, N'PIECE', N'ADD_ON'), -- Seed çifti P005/S020 (PIECE, ADD_ON)
    (N'd5017b34-1f0a-5f11-9ce4-f852967dd034', N'P006', N'S021', 200.00, N'PIECE', N'BASE'), -- Seed çifti P006/S021 (PIECE, BASE)
    (N'ff6f3543-c19a-5afc-b344-cc7ff082d9ce', N'P006', N'S022', 80.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P006/S022 (PIECE, ALTERNATIVE)
    (N'44afe328-3d55-5baa-89c5-dc3821d9d9d4', N'P006', N'S023', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P006/S023 (PIECE, ADD_ON; terzi kalemi 1)
    (N'136cf19a-0acf-5402-a85a-7d5e2bc3a3b4', N'P006', N'S024', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P006/S024 (PIECE, ADD_ON; terzi kalemi 3)
    (N'0dccfd03-2663-520a-8d2d-3bc035433669', N'P006', N'S025', 180.00, N'PIECE', N'ADD_ON'), -- Seed çifti P006/S025 (PIECE, ADD_ON; terzi kalemi 4)
    (N'7e1cdd23-00e7-5c8d-a751-13f490adffa7', N'P006', N'S019', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P006/S019 (PIECE, ADD_ON; terzi kalemi 5)
    (N'3efd0962-1f09-53d8-9888-24264d106701', N'P006', N'S026', 160.00, N'PIECE', N'ADD_ON'), -- Seed çifti P006/S026 (PIECE, ADD_ON)
    (N'10de9ab5-8421-50e4-a9f6-d09da1cb7a60', N'P007', N'S027', 200.00, N'PIECE', N'BASE'), -- Seed çifti P007/S027 (PIECE, BASE)
    (N'83279365-0f54-563d-9724-8d95ee7f4fd9', N'P007', N'S012', 70.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P007/S012 (PIECE, ALTERNATIVE)
    (N'8181449b-f73d-5226-be79-4fc271db0ed9', N'P007', N'S028', 130.00, N'PIECE', N'ADD_ON'), -- Seed çifti P007/S028 (PIECE, ADD_ON; terzi kalemi 11)
    (N'c3db3f19-fbe9-5af8-9da4-6797d0b9ffb0', N'P007', N'S029', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P007/S029 (PIECE, ADD_ON)
    (N'2c8db104-6687-5bb7-b6cb-ed951d965e31', N'P007', N'S030', 140.00, N'PIECE', N'ADD_ON'), -- Seed çifti P007/S030 (PIECE, ADD_ON; terzi kalemi 5)
    (N'574da846-3902-5309-9358-c19ec95141ff', N'P008', N'S031', 250.00, N'PIECE', N'BASE'), -- Seed çifti P008/S031 (PIECE, BASE)
    (N'dfbe1c95-b2e4-5ffc-94d8-c6e6b6a8eedf', N'P008', N'S032', 150.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P008/S032 (PIECE, ALTERNATIVE)
    (N'0f3cd1c5-f3d5-56db-b237-0e9f4e38a6d4', N'P008', N'S033', 160.00, N'PIECE', N'ADD_ON'), -- Seed çifti P008/S033 (PIECE, ADD_ON)
    (N'59f852ed-63ca-5141-809f-1d0322379f96', N'P009', N'S027', 500.00, N'PIECE', N'BASE'), -- Seed çifti P009/S027 (PIECE, BASE)
    (N'24c025ed-43ed-5245-a860-502715c13a32', N'P009', N'S012', 300.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P009/S012 (PIECE, ALTERNATIVE)
    (N'59b74e64-e390-5651-9a25-13dff0367972', N'P009', N'S028', 160.00, N'PIECE', N'ADD_ON'), -- Seed çifti P009/S028 (PIECE, ADD_ON; terzi kalemi 11)
    (N'ae25e3e4-f5ef-5555-93b4-d1336e99bd28', N'P009', N'S009', 180.00, N'PIECE', N'ADD_ON'), -- Seed çifti P009/S009 (PIECE, ADD_ON)
    (N'5400b5c1-22a2-57bd-9fb6-5bff636ad746', N'P009', N'S030', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P009/S030 (PIECE, ADD_ON; terzi kalemi 7)
    (N'fe223abf-3dec-56aa-8691-52a119923a5e', N'P010', N'S027', 300.00, N'PIECE', N'BASE'), -- Seed çifti P010/S027 (PIECE, BASE)
    (N'729bac56-74ff-5e04-bc2c-42dd679fae05', N'P010', N'S034', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P010/S034 (PIECE, ADD_ON)
    (N'338f384d-dffc-5951-835f-15235bb74d95', N'P010', N'S035', 140.00, N'PIECE', N'ADD_ON'), -- Seed çifti P010/S035 (PIECE, ADD_ON)
    (N'c6b6a2bc-f2c8-53d6-9126-17486306581d', N'P011', N'S011', 200.00, N'PIECE', N'BASE'), -- Seed çifti P011/S011 (PIECE, BASE)
    (N'08366dac-04af-5597-b84a-90e7b07a4a8e', N'P011', N'S034', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P011/S034 (PIECE, ADD_ON)
    (N'79cf69f8-7941-5883-bc9a-f084e7ccb1ae', N'P011', N'S036', 110.00, N'PIECE', N'ADD_ON'), -- Seed çifti P011/S036 (PIECE, ADD_ON)
    (N'63820a60-91b6-5a1f-9863-71d2052dfa8e', N'P012', N'S037', 300.00, N'PIECE', N'BASE'), -- Seed çifti P012/S037 (PIECE, BASE)
    (N'f87ee92d-0857-5c96-a11f-075d1d09bc6c', N'P012', N'S022', 100.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P012/S022 (PIECE, ALTERNATIVE)
    (N'17554fce-8570-507b-86db-bb3519e28741', N'P012', N'S038', 200.00, N'PIECE', N'ADD_ON'), -- Seed çifti P012/S038 (PIECE, ADD_ON; terzi kalemi 8)
    (N'4f674ff0-1364-5e5e-b49c-00b31038a6a7', N'P012', N'S039', 280.00, N'PIECE', N'ADD_ON'), -- Seed çifti P012/S039 (PIECE, ADD_ON; terzi kalemi 9)
    (N'aec03478-fcf5-54ad-8262-7a7a16d5ad99', N'P012', N'S009', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P012/S009 (PIECE, ADD_ON; terzi kalemi 13)
    (N'a42fbb7f-2de2-54f5-a2c6-27ca79375a02', N'P012', N'S040', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P012/S040 (PIECE, ADD_ON; terzi kalemi 15)
    (N'4d2ff2c1-327f-5fad-abd7-d1ead1a29b48', N'P013', N'S041', 500.00, N'PIECE', N'BASE'), -- Seed çifti P013/S041 (PIECE, BASE)
    (N'b074b5d6-38b6-57fa-8008-fae6efb61626', N'P013', N'S042', 200.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P013/S042 (PIECE, ALTERNATIVE)
    (N'e12616c7-566e-5af0-abf0-837afbb6bda3', N'P013', N'S043', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P013/S043 (PIECE, ADD_ON)
    (N'd2716a12-4119-5418-ba22-5b12ccdae116', N'P013', N'S028', 300.00, N'PIECE', N'ADD_ON'), -- Seed çifti P013/S028 (PIECE, ADD_ON)
    (N'608b1e3f-d39c-50bf-bc19-fadcab18d4ad', N'P013', N'S044', 450.00, N'PIECE', N'ADD_ON'), -- Seed çifti P013/S044 (PIECE, ADD_ON)
    (N'8d0ae8ac-80dd-5dc4-a692-2bea4d6ebda9', N'P013', N'S045', 50.00, N'PIECE', N'ADD_ON'), -- Seed çifti P013/S045 (PIECE, ADD_ON; terzi kalemi 16)
    (N'5155d4f0-23de-5908-adbb-def2b9849af7', N'P014', N'S027', 500.00, N'PIECE', N'BASE'), -- Seed çifti P014/S027 (PIECE, BASE)
    (N'9524a1d4-1766-533e-9b69-20bde4c4449e', N'P014', N'S046', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P014/S046 (PIECE, ADD_ON; terzi kalemi 6)
    (N'7c1740b7-e861-50be-a3be-fe3541c637b4', N'P014', N'S047', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P014/S047 (PIECE, ADD_ON; terzi kalemi 15)
    (N'56f34399-90e5-5a15-bd72-be1d49760eab', N'P015', N'S048', 550.00, N'PIECE', N'BASE'), -- Seed çifti P015/S048 (PIECE, BASE)
    (N'0d422cef-735c-512d-adf3-e747668674d5', N'P015', N'S019', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P015/S019 (PIECE, ADD_ON)
    (N'9d050108-7954-5128-89ba-f71f41a72ae0', N'P015', N'S049', 180.00, N'PIECE', N'ADD_ON'), -- Seed çifti P015/S049 (PIECE, ADD_ON; terzi kalemi 15)
    (N'b6311b21-6349-5ed5-960d-7f58d97730d4', N'P016', N'S050', 600.00, N'PIECE', N'BASE'), -- Seed çifti P016/S050 (PIECE, BASE)
    (N'783fd686-6815-572f-b7b0-62cb28e15082', N'P016', N'S051', 320.00, N'PIECE', N'ADD_ON'), -- Seed çifti P016/S051 (PIECE, ADD_ON)
    (N'8a15cd99-5175-5910-916a-174216e063df', N'P017', N'S052', 500.00, N'PIECE', N'BASE'), -- Seed çifti P017/S052 (PIECE, BASE)
    (N'4653c153-4e21-56ad-aee0-9c63d6334cdb', N'P017', N'S019', 200.00, N'PIECE', N'ADD_ON'), -- Seed çifti P017/S019 (PIECE, ADD_ON)
    (N'40f34b21-8dda-5814-99b7-353ef4780ed5', N'P018', N'S053', 500.00, N'PIECE', N'BASE'), -- Seed çifti P018/S053 (PIECE, BASE)
    (N'ea064f7c-39f8-59ce-81a9-b63000e556b9', N'P018', N'S054', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P018/S054 (PIECE, ADD_ON)
    (N'6072d329-4b6f-5eaa-bff6-7a5b05e51305', N'P018', N'S055', 240.00, N'PIECE', N'ADD_ON'), -- Seed çifti P018/S055 (PIECE, ADD_ON)
    (N'9ba28051-19f5-5c22-a971-2852d514e38b', N'P018', N'S056', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P018/S056 (PIECE, ADD_ON)
    (N'6574f45c-ad9b-59d6-9fa3-20cc0bb6a8a4', N'P019', N'S057', 1000.00, N'PIECE', N'BASE'), -- Seed çifti P019/S057 (PIECE, BASE)
    (N'a7554c7c-ac36-58b6-99e0-8f38a132f769', N'P019', N'S058', 550.00, N'PIECE', N'ADD_ON'), -- Seed çifti P019/S058 (PIECE, ADD_ON)
    (N'b74b3ccd-9faf-5c24-ae04-2e6d6b9e4fe5', N'P019', N'S059', 350.00, N'PIECE', N'ADD_ON'), -- Seed çifti P019/S059 (PIECE, ADD_ON)
    (N'6d3e58f0-1c81-5b89-beda-808d9c7c2bdb', N'P019', N'S060', 400.00, N'PIECE', N'ADD_ON'), -- Seed çifti P019/S060 (PIECE, ADD_ON)
    (N'd1cfdc23-5081-5baa-af9f-e0edd8519ccb', N'P020', N'S061', 500.00, N'PIECE', N'BASE'), -- Seed çifti P020/S061 (PIECE, BASE)
    (N'8ca30afc-77b5-5028-8e1f-5d23ccc66b74', N'P020', N'S019', 220.00, N'PIECE', N'ADD_ON'), -- Seed çifti P020/S019 (PIECE, ADD_ON)
    (N'9c746a8f-56ff-5c79-91d5-980dc9811ca8', N'P021', N'S062', 1000.00, N'PIECE', N'BASE'), -- Seed çifti P021/S062 (PIECE, BASE)
    (N'47ec2fc6-bd1a-575f-a50e-a154e97f5c9f', N'P021', N'S063', 300.00, N'PIECE', N'ADD_ON'), -- Seed çifti P021/S063 (PIECE, ADD_ON)
    (N'863a783a-9e73-50f0-94bb-adb40ee82478', N'P022', N'S064', 1500.00, N'PIECE', N'BASE'), -- Seed çifti P022/S064 (PIECE, BASE)
    (N'0c952486-3471-5264-bbff-bae0e9fadc7e', N'P022', N'S065', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P022/S065 (PIECE, ADD_ON)
    (N'6d1df6b4-1b13-5e92-b297-fe12a8378e97', N'P022', N'S066', 350.00, N'PIECE', N'ADD_ON'), -- Seed çifti P022/S066 (PIECE, ADD_ON)
    (N'493267bd-6649-59fe-8a2c-d182cb3aa942', N'P023', N'S064', 1000.00, N'PIECE', N'BASE'), -- Seed çifti P023/S064 (PIECE, BASE)
    (N'4ddd086b-60ac-5c71-b08b-48c6e267a7b0', N'P023', N'S065', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P023/S065 (PIECE, ADD_ON)
    (N'b3f197ec-0dfa-574a-a851-487f7d9547dd', N'P023', N'S066', 350.00, N'PIECE', N'ADD_ON'), -- Seed çifti P023/S066 (PIECE, ADD_ON)
    (N'4d8ecb3c-2d77-551c-90fa-bb3937d74d85', N'P024', N'S067', 1000.00, N'PIECE', N'BASE'), -- Seed çifti P024/S067 (PIECE, BASE)
    (N'5a6085a2-051e-527f-9c01-402b4f428eb1', N'P024', N'S068', 400.00, N'PIECE', N'ADD_ON'), -- Seed çifti P024/S068 (PIECE, ADD_ON)
    (N'030afc3d-df92-5fe6-9c18-5259e323faba', N'P025', N'S069', 500.00, N'PIECE', N'BASE'), -- Seed çifti P025/S069 (PIECE, BASE)
    (N'c6d4b337-383a-5a8a-a165-37dca0d706e3', N'P025', N'S022', 200.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P025/S022 (PIECE, ALTERNATIVE)
    (N'2d674d78-868a-5370-91e4-7d6799733bbc', N'P025', N'S070', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P025/S070 (PIECE, ADD_ON)
    (N'c49cc561-41f7-5d6c-af74-40ff9a6aa3f1', N'P025', N'S071', 180.00, N'PIECE', N'ADD_ON'), -- Seed çifti P025/S071 (PIECE, ADD_ON)
    (N'cf81797f-bff3-5384-b7c3-c0188311f3b5', N'P025', N'S072', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P025/S072 (PIECE, ADD_ON)
    (N'0be51b4c-73b1-5292-a599-e8729450fd64', N'P026', N'S073', 600.00, N'PIECE', N'BASE'), -- Seed çifti P026/S073 (PIECE, BASE)
    (N'da0599ce-a729-5a3f-8a4e-1ba1a2f3d0cc', N'P026', N'S022', 250.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P026/S022 (PIECE, ALTERNATIVE)
    (N'c19a11a7-c2cc-5bd2-8f8a-926588a9fa81', N'P026', N'S074', 450.00, N'PIECE', N'ADD_ON'), -- Seed çifti P026/S074 (PIECE, ADD_ON)
    (N'2c95e22e-863d-5d58-b5d8-daaa88c160dd', N'P027', N'S075', 800.00, N'PIECE', N'BASE'), -- Seed çifti P027/S075 (PIECE, BASE)
    (N'58656a47-402c-5f34-9b72-8845fa5e87ed', N'P027', N'S076', 250.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P027/S076 (PIECE, ALTERNATIVE)
    (N'b6d8630b-f174-5c78-abab-e8ac685988d0', N'P027', N'S028', 200.00, N'PIECE', N'ADD_ON'), -- Seed çifti P027/S028 (PIECE, ADD_ON; terzi kalemi 11)
    (N'bc32c8cb-5acf-5944-9122-aeeace094080', N'P027', N'S077', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P027/S077 (PIECE, ADD_ON)
    (N'215e3c16-6628-5246-8a75-c68288c60b61', N'P027', N'S078', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P027/S078 (PIECE, ADD_ON)
    (N'6a4f3cb2-2f67-5375-8eb1-d7040e7facdc', N'P028', N'S079', 1200.00, N'PIECE', N'BASE'), -- Seed çifti P028/S079 (PIECE, BASE)
    (N'eb467644-5a47-5166-9a5a-5aa0b15445ee', N'P028', N'S076', 350.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P028/S076 (PIECE, ALTERNATIVE)
    (N'4dfa249c-c972-5177-afe0-dc176347ba7c', N'P028', N'S080', 350.00, N'PIECE', N'ADD_ON'), -- Seed çifti P028/S080 (PIECE, ADD_ON)
    (N'b7c1896f-6c7e-55e4-8624-a87f7804654f', N'P028', N'S081', 200.00, N'PIECE', N'ADD_ON'), -- Seed çifti P028/S081 (PIECE, ADD_ON)
    (N'9aa6767b-98ad-55c2-88dc-6abbeafcf752', N'P028', N'S030', 180.00, N'PIECE', N'ADD_ON'), -- Seed çifti P028/S030 (PIECE, ADD_ON; terzi kalemi 7)
    (N'86c829f0-0c76-5b7f-b800-a90f6483280f', N'P029', N'S082', 3000.00, N'PIECE', N'BASE'), -- Seed çifti P029/S082 (PIECE, BASE)
    (N'8b89b1cb-30db-5581-9db3-70470b0f4877', N'P029', N'S076', 1000.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P029/S076 (PIECE, ALTERNATIVE)
    (N'af46f290-d53d-580d-b689-7425f95914ee', N'P029', N'S083', 500.00, N'PIECE', N'ADD_ON'), -- Seed çifti P029/S083 (PIECE, ADD_ON)
    (N'06acef67-3bb7-5d67-b0a4-a22080df5b48', N'P030', N'S084', 4000.00, N'PIECE', N'BASE'), -- Seed çifti P030/S084 (PIECE, BASE)
    (N'c8dd76de-c741-52b7-92ec-24c066fe1322', N'P030', N'S085', 400.00, N'PIECE', N'ADD_ON'), -- Seed çifti P030/S085 (PIECE, ADD_ON)
    (N'b2c486e8-05f5-541e-9ba6-dbf26304520a', N'P030', N'S086', 700.00, N'PIECE', N'ADD_ON'), -- Seed çifti P030/S086 (PIECE, ADD_ON)
    (N'8324c683-80ee-55ca-9c2c-b23094838390', N'P031', N'S087', 900.00, N'PIECE', N'BASE'), -- Seed çifti P031/S087 (PIECE, BASE)
    (N'5ad19d24-c98a-538e-b174-5e3914b6a6dd', N'P031', N'S088', 250.00, N'PIECE', N'ADD_ON'), -- Seed çifti P031/S088 (PIECE, ADD_ON)
    (N'9ce6c74d-af52-5636-b316-3fa39a9e1482', N'P032', N'S089', 300.00, N'PIECE', N'BASE'), -- Seed çifti P032/S089 (PIECE, BASE)
    (N'28958333-f05f-5ce7-a09e-390c5907689e', N'P032', N'S090', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P032/S090 (PIECE, ADD_ON)
    (N'9d3fa7ea-9a8e-57b9-9a53-8116cd07a65f', N'P033', N'S091', 600.00, N'PIECE', N'BASE'), -- Seed çifti P033/S091 (PIECE, BASE)
    (N'2968e3f6-fedc-58bf-8cec-2fd87be34069', N'P033', N'S092', 50.00, N'PIECE', N'ADD_ON'), -- Seed çifti P033/S092 (PIECE, ADD_ON)
    (N'fdf777bf-dfdf-5b7f-a448-77d0e8673b95', N'P033', N'S093', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P033/S093 (PIECE, ADD_ON)
    (N'38dcc40d-cf48-5c5a-ad0a-ff7841e9129c', N'P034', N'S094', 800.00, N'PIECE', N'BASE'), -- Seed çifti P034/S094 (PIECE, BASE)
    (N'51a0963c-eb7d-5c3e-b808-82a071afbcc3', N'P034', N'S095', 50.00, N'PIECE', N'ADD_ON'), -- Seed çifti P034/S095 (PIECE, ADD_ON)
    (N'd92334bf-57e8-59e1-afb6-5f1816855444', N'P034', N'S096', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P034/S096 (PIECE, ADD_ON)
    (N'96fe4fc0-341c-5691-b90e-979b4da8062c', N'P035', N'S097', 1000.00, N'PIECE', N'BASE'), -- Seed çifti P035/S097 (PIECE, BASE)
    (N'bdf7bb3e-7331-5cb2-b5a0-e10061e1f352', N'P035', N'S040', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P035/S040 (PIECE, ADD_ON)
    (N'8b0f8221-e7e2-5493-9c16-76d027a8fe58', N'P036', N'S098', 400.00, N'PIECE', N'BASE'), -- Seed çifti P036/S098 (PIECE, BASE)
    (N'a105a0fc-11ec-5fd3-9a0d-4cfb6f1265b9', N'P036', N'S099', 60.00, N'PIECE', N'ADD_ON'), -- Seed çifti P036/S099 (PIECE, ADD_ON)
    (N'2f2e1c66-591e-5e83-a1ee-53731a208bf3', N'P036', N'S100', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P036/S100 (PIECE, ADD_ON)
    (N'a9118846-5e4a-5633-9b5e-4dd355e4d12a', N'P037', N'S098', 500.00, N'PIECE', N'BASE'), -- Seed çifti P037/S098 (PIECE, BASE)
    (N'b3621add-b76e-50dc-8019-8ca51813cf31', N'P037', N'S099', 60.00, N'PIECE', N'ADD_ON'), -- Seed çifti P037/S099 (PIECE, ADD_ON)
    (N'6ddfe1d0-2253-5619-af3a-d1d2c2b0dd17', N'P037', N'S100', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P037/S100 (PIECE, ADD_ON)
    (N'26b01055-338b-55dc-bb45-0648198ed0ec', N'P038', N'S101', 350.00, N'PIECE', N'BASE'), -- Seed çifti P038/S101 (PIECE, BASE)
    (N'f5c50751-e735-5942-b9c2-4245a76150bb', N'P038', N'S102', 150.00, N'PIECE', N'ADD_ON'), -- Seed çifti P038/S102 (PIECE, ADD_ON)
    (N'6b958d0f-6ebd-545a-b4e3-6f5ca6d57870', N'P038', N'S103', 130.00, N'PIECE', N'ADD_ON'), -- Seed çifti P038/S103 (PIECE, ADD_ON)
    (N'687d757c-a4fc-52f5-9f1f-20a799de6f6e', N'P039', N'S101', 350.00, N'PIECE', N'BASE'), -- Seed çifti P039/S101 (PIECE, BASE)
    (N'a304f7aa-5de9-50bb-878b-421a7d501b29', N'P039', N'S103', 130.00, N'PIECE', N'ADD_ON'), -- Seed çifti P039/S103 (PIECE, ADD_ON)
    (N'9786a9fe-2951-5104-b456-8917b29a5951', N'P040', N'S104', 150.00, N'M2', N'BASE'), -- Seed çifti P040/S104 (M2, BASE)
    (N'0f132f4a-64e8-517f-9353-5038f802493e', N'P040', N'S028', 120.00, N'M2', N'ADD_ON'), -- Seed çifti P040/S028 (M2, ADD_ON)
    (N'f3f57de4-525b-5046-8647-dd99f29418ff', N'P040', N'S105', 100.00, N'M2', N'ADD_ON'), -- Seed çifti P040/S105 (M2, ADD_ON)
    (N'd56ae07a-fbec-5238-8965-827dcb51b80b', N'P041', N'S106', 220.00, N'M2', N'BASE'), -- Seed çifti P041/S106 (M2, BASE)
    (N'3da596d1-e66c-5694-ae4e-278aeda322f5', N'P041', N'S013', 140.00, N'M2', N'ADD_ON'), -- Seed çifti P041/S013 (M2, ADD_ON)
    (N'72115bb5-c3e6-5e39-94e7-adef265b09c9', N'P042', N'S107', 160.00, N'PIECE', N'BASE'), -- Seed çifti P042/S107 (PIECE, BASE)
    (N'7f9f3dee-87e0-5833-af04-c64df73b0f6e', N'P042', N'S108', 80.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P042/S108 (PIECE, ALTERNATIVE)
    (N'455ccf24-3d3c-5076-92e1-2b15a0a45225', N'P042', N'S109', 80.00, N'PIECE', N'ADD_ON'), -- Seed çifti P042/S109 (PIECE, ADD_ON)
    (N'0631b3cb-0172-542a-a005-75b516b7184a', N'P043', N'S011', 100.00, N'PIECE', N'BASE'), -- Seed çifti P043/S011 (PIECE, BASE)
    (N'c602fe4d-5d1b-5c58-a83f-151c10a660fe', N'P043', N'S110', 150.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P043/S110 (PIECE, ALTERNATIVE)
    (N'8f5ec4ac-60cc-5d2e-acd6-ae442680414f', N'P043', N'S019', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P043/S019 (PIECE, ADD_ON)
    (N'065039d5-eb8d-5965-b25c-4213d0c5de07', N'P044', N'S111', 300.00, N'PIECE', N'BASE'), -- Seed çifti P044/S111 (PIECE, BASE)
    (N'9c57262e-92c0-5254-b10c-e5aced8fe3a9', N'P044', N'S112', 220.00, N'PIECE', N'ALTERNATIVE'), -- Seed çifti P044/S112 (PIECE, ALTERNATIVE)
    (N'15eeec09-c5f1-55cb-97da-c66b2c0040a8', N'P045', N'S113', 200.00, N'PIECE', N'BASE'), -- Seed çifti P045/S113 (PIECE, BASE)
    (N'398ccccd-ac41-5963-8c75-1d9ef7f79371', N'P045', N'S114', 100.00, N'PIECE', N'ADD_ON'), -- Seed çifti P045/S114 (PIECE, ADD_ON)
    (N'5ce2c3cf-15ac-5539-8e1a-0038ec4adf57', N'P046', N'S115', 100.00, N'PIECE', N'BASE'), -- Seed çifti P046/S115 (PIECE, BASE)
    (N'3e8b91bc-2354-5468-a0f3-e9d8437112b1', N'P046', N'S116', 50.00, N'PIECE', N'ADD_ON'), -- Seed çifti P046/S116 (PIECE, ADD_ON)
    (N'e782627c-7ff6-5423-a5a1-9e28c9f0acfd', N'P047', N'S117', 300.00, N'PIECE', N'BASE'), -- Seed çifti P047/S117 (PIECE, BASE)
    (N'998252d1-4aad-594f-a81f-f6c66221f7fb', N'P047', N'S118', 120.00, N'PIECE', N'ADD_ON'), -- Seed çifti P047/S118 (PIECE, ADD_ON)
    (N'792364ff-7eeb-56b7-be97-92e8ae866dcd', N'P047', N'S119', 40.00, N'PIECE', N'ADD_ON'), -- Seed çifti P047/S119 (PIECE, ADD_ON)
    (N'afc91a3c-c4bf-51bc-986b-0064ee0b843c', N'P048', N'S120', 200.00, N'PIECE', N'BASE'), -- Seed çifti P048/S120 (PIECE, BASE)
    (N'503347b6-03c8-51be-8c07-d5c66e50f7bf', N'P048', N'S121', 80.00, N'PIECE', N'ADD_ON'); -- Seed çifti P048/S121 (PIECE, ADD_ON)

-- Kapsam dışı terzi kalemi 2: Ayrı bir mevcut ürün/hizmet çifti yok; P006/S023 zaten 120 TL ile eşlenmiştir.
-- Kapsam dışı terzi kalemi 14: Kullanıcı ağ aşınması/yama onarımını kapsam dışında bıraktı; pantolonda bu işlemin mevcut çifti yok.
INSERT @ExcludedPairs (product_code, service_code) VALUES
    (N'P039', N'S102'); -- Kapsam dışında P039/S102: Boncuklu/taşlı/güpürlü yatak örtüsünde hassas işlem farkı çift ücret oluşturabilir.

BEGIN TRY
    BEGIN TRANSACTION;

    -- Kod/GUID uyuşmazlığı varsa hiçbir kalıcı değişiklik yapılmadan durulur.
    IF EXISTS (SELECT 1 FROM [catalog].product_categories t WITH (UPDLOCK, HOLDLOCK) JOIN @SeedCategories s ON s.code = t.code WHERE t.id <> s.id)
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: kategori.', 1;
    IF EXISTS (SELECT 1 FROM [catalog].product_types t WITH (UPDLOCK, HOLDLOCK) JOIN @SeedProducts s ON s.code = t.code WHERE t.id <> s.id)
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ürün.', 1;
    IF EXISTS (SELECT 1 FROM [catalog].services t WITH (UPDLOCK, HOLDLOCK) JOIN @SeedServices s ON s.code = t.code WHERE t.id <> s.id)
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: hizmet.', 1;
    IF EXISTS (
        SELECT 1 FROM [catalog].product_type_services t WITH (UPDLOCK, HOLDLOCK)
        JOIN @SeedProducts p ON p.id = t.product_type_id
        JOIN @SeedServices v ON v.id = t.service_id
        JOIN @SeedPairs s ON s.product_code = p.code AND s.service_code = v.code
        WHERE t.id <> s.id
    ) THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ürün/hizmet çifti.', 1;

    -- Kategoriler, ürünler ve hizmetler: mevcut kimlikleri koru, yalnız eksikleri ekle.
    UPDATE t SET name = s.name, sort_order = s.sort_order,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].product_categories t JOIN @SeedCategories s ON s.code = t.code;
    INSERT [catalog].product_categories (id, code, name, sort_order, is_active)
    SELECT s.id, s.code, s.name, s.sort_order, 1 FROM @SeedCategories s
    WHERE NOT EXISTS (SELECT 1 FROM [catalog].product_categories t WITH (UPDLOCK, HOLDLOCK) WHERE t.code = s.code);

    UPDATE t SET category_id = c.id, name = s.name, base_unit = s.base_unit,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].product_types t JOIN @SeedProducts s ON s.code = t.code
    JOIN @SeedCategories c ON c.code = s.category_code;
    INSERT [catalog].product_types (id, category_id, code, name, base_unit, is_active)
    SELECT s.id, c.id, s.code, s.name, s.base_unit, 1 FROM @SeedProducts s
    JOIN @SeedCategories c ON c.code = s.category_code
    WHERE NOT EXISTS (SELECT 1 FROM [catalog].product_types t WITH (UPDLOCK, HOLDLOCK) WHERE t.code = s.code);

    UPDATE t SET name = s.name, is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].services t JOIN @SeedServices s ON s.code = t.code;
    INSERT [catalog].services (id, code, name, is_active)
    SELECT s.id, s.code, s.name, 1 FROM @SeedServices s
    WHERE NOT EXISTS (SELECT 1 FROM [catalog].services t WITH (UPDLOCK, HOLDLOCK) WHERE t.code = s.code);

    -- Çiftler: fiyat/birim kararlarını uygula; başlangıçta hiçbir hizmet seçili değildir.
    UPDATE t SET default_price = s.default_price, currency = 'TRY', price_unit = s.price_unit,
        selection_kind = s.selection_kind, is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].product_type_services t
    JOIN @SeedProducts p ON p.id = t.product_type_id
    JOIN @SeedServices v ON v.id = t.service_id
    JOIN @SeedPairs s ON s.product_code = p.code AND s.service_code = v.code;
    INSERT [catalog].product_type_services
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    SELECT s.id, p.id, v.id, s.default_price, 'TRY', s.price_unit, s.selection_kind, 0, 1
    FROM @SeedPairs s JOIN @SeedProducts p ON p.code = s.product_code
    JOIN @SeedServices v ON v.code = s.service_code
    WHERE NOT EXISTS (
        SELECT 1 FROM [catalog].product_type_services t WITH (UPDLOCK, HOLDLOCK)
        WHERE t.product_type_id = p.id AND t.service_id = v.id
    );

    -- Kapsam dışı çiftleri ekleme; önceki dağıtımdan kaldılarsa pasifleştir.
    UPDATE t SET is_active = 0, is_default_selected = 0, update_date = SYSUTCDATETIME()
    FROM [catalog].product_type_services t
    JOIN [catalog].product_types p ON p.id = t.product_type_id
    JOIN [catalog].services v ON v.id = t.service_id
    JOIN @ExcludedPairs s ON s.product_code = p.code AND s.service_code = v.code;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

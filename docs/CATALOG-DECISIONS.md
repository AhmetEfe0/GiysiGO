# Katalog Seed Kararları

Bu belge, #11 kapsamında kullanıcıdan tek tek alınan kararları kaydeder. Kaynak liste `catalog-draft.json`, makine tarafından okunan kararlar `catalog-decisions.json` dosyasındadır.

## Hizmet seçimi

- Ürün ilk açıldığında hiçbir hizmet seçili değildir. Kaynaktaki `[x]` işareti başlangıç seçimi veya zorunluluk anlamına gelmez.
- Devam etmek için en az bir `BASE` veya `ALTERNATIVE` hizmet seçilmelidir. Yalnızca `ADD_ON` seçmek yeterli değildir.
- Bu kural `ordering.spCheckoutCart` içinde her ürün için sunucuda denetlenir. Hiç hizmet seçilmemesi ve yalnız ek hizmet seçilmesi `51006` hatasıyla reddedilir.
- Ürün ve hizmetler veritabanı kayıtlarıdır; hizmetler enum'a dönüştürülmez.

## Birim ve özel hizmet kararları

- Üç perde tadilatı `M2` ile fiyatlanır: `P040/S028` (120 TL), `P040/S105` (100 TL), `P041/S013` (140 TL).
- `P037/S099` büyük boy battaniye farkı aktif bir `ADD_ON` olarak kalır.
- `P039/S102` hassas işlem farkı, olası çift ücret nedeniyle seed dışında bırakılır. Önceden eklenmişse pasifleştirilir.
- `P044/S112` yastık özel yıkaması aktif bir `ALTERNATIVE` olarak eklenir.

## Sadece Terzi eşleşmeleri

Yeni veya yinelenen hizmet oluşturulmaz. Mevcut ürün/hizmet çiftleri ve bu çiftlerin mevcut fiyatları kullanılır.

| Sıra | Kaynak kalem | Onaylanan eşleşmeler ve fiyatlar |
| --- | --- | --- |
| 1 | Paça Kısaltma (Düz Kumaş) | `P006/S023` — 120 TL |
| 2 | Paça Kısaltma (Orijinal Kot) | Seed dışında; ayrı mevcut çift yok, `P006/S023` 120 TL kalır |
| 3 | Paça Kısaltma (Duble Paça) | `P006/S024` — 150 TL |
| 4 | Bel Daraltma / Genişletme | `P006/S025` — 180 TL |
| 5 | Pantolon / Etek Fermuar Değişimi | `P006/S019` — 150 TL; `P007/S030` — 140 TL |
| 6 | Mont / Kaban Kemik Fermuar Değişimi | Yalnız `P014/S046` Mont — 250 TL; kaban çifti eklenmez |
| 7 | Elbise Gizli Fermuar Değişimi | `P009/S030` Günlük Elbise — 150 TL; `P028/S030` Taşlı/Pullu/Şifon Abiye — 180 TL |
| 8 | Ceket Kol Kısaltma (Düz) | `P012/S038` — 200 TL |
| 9 | Ceket Kol Kısaltma (Düğmeli) | `P012/S039` — 280 TL |
| 10 | Gömlek Kol Kısaltma (Manşetli) | `P001/S003` — 150 TL |
| 11 | Etek / Elbise Boy Kısaltma | `P007/S028` Etek — 130 TL; `P009/S028` Günlük Elbise — 160 TL; `P027/S028` Sade Abiye — 200 TL |
| 12 | Beden Daraltma (Gömlek/Bluz) | `P001/S004` Gömlek — 120 TL; `P002/S009` Bluz — 140 TL |
| 13 | Ceket / Kaban Beden Daraltma | Yalnız `P012/S009` Ceket/Blazer — 250 TL; kaban çifti eklenmez |
| 14 | Ağ Aşınması / Yama Onarımı | Seed dışında; pantolonda mevcut karşılık yok; mont yamasına eşlenmez |
| 15 | Sökük / Küçük Yırtık Tamiri | `P002/S010` Bluz — 70 TL; `P003/S014` Tişört — 60 TL; `P012/S040` Ceket Astarı — 150 TL; `P014/S047` Mont Yaması — 150 TL; `P015/S049` Tüylü Mont — 180 TL |
| 16 | Düğme / Çıtçıt Dikimi (Adet) | `P001/S005` Gömlek — 30 TL; `P013/S045` Kaban/Palto — 50 TL |

16 kalemin tamamı karara bağlanmıştır: 14 kalem 24 mevcut ürün/hizmet çiftine eşlenmiştir; 2 ve 14 numaralı kalemler kapsam dışıdır. Eşleşmeler aynı mevcut kayıtlara işaret eder; ek ücret veya yinelenen kayıt oluşturmaz.

## Kayıt kimliği ve tekrar çalıştırma

- Kategori, ürün ve hizmet kodları kaynaktaki sabit kodlardır (`DAILY`, `P001`, `S001` gibi).
- GUID değerleri sabit bir ad alanı ve kaynak kodlarından UUIDv5 yöntemiyle türetilir. Ürün/hizmet ilişkisi iki kaynak koduyla belirlenir.
- Seed tekrar çalıştırıldığında aynı kod ve çiftlere ait kayıtlar güncellenir; yeni kopya eklenmez.
- Aynı kod veya çift farklı bir GUID ile kayıtlıysa işlem durdurulur ve geri alınır; ilişkiler sessizce değiştirilmez.
- Kapsam dışı veya karar bekleyen çiftler aktif sunulmaz. Önceden mevcutlarsa pasifleştirilir.
- Üretim: `node docs/generate-catalog-seed.mjs`. Üretilen `CatalogSeed.sql` doğrudan düzenlenmez.
- Üretici kaynak ve karar doğrulamasını yapar; `catalog-seed-sql.mjs` okunabilir veri tablolarını ve ortak `UPDATE`/`INSERT` sorgularını üretir. GUID üretimi ve kullanıcı kararları değişmez. `.gitattributes` iki üretilen seed dosyasını GitHub incelemesinde daraltılmak üzere işaretler; kaynak ve SQL üreticisi açıkça incelenebilir.

## Yerel doğrulama

`powershell -ExecutionPolicy Bypass -File scripts/Test-CatalogData.ps1` komutu kurulu Visual Studio araçlarını otomatik bulur; kalıcı PATH değişikliği gerektirmez. Node.js ve .NET SDK komutları terminalden erişilebilir olmalıdır. SQL Server 2022 LocalDB (16.x) gereklidir; script bu sürümü açıkça seçer, sunucudan ana sürümü doğrular ve uyumsuz platform yüklemesini kapatır. Eski sürüme otomatik geçmez.

Script seed'i üretir, DACPAC'i derler ve yalnız bu çalıştırma için oluşturulan ayrı bir LocalDB örneğine yükler. Katalog testleri seed'i iki kez çalıştırıp kimliklerin, ilişkilerin ve fiyatların korunduğunu, kapsam dışı çiftin pasifleştirildiğini denetler. Gerçek checkout prosedüründe boş seçim ve yalnız ek hizmet seçimi reddedilir; BASE veya ALTERNATIVE ile ek hizmetin birlikte kabul edildiği sınanır. Ardından gerçek HTTP okumaları, API yazma sınırları, Ordering regresyonları ve ortak sözleşme testleri çalışır. Test veritabanı ve ayrılmış LocalDB örneği sonunda temizlenir.

Seed düzenlemesi karşılaştırılırken `-BaselineCatalogSeedPath <eski-seed.sql>` verilebilir. Script önce belirtilen eski sürümü, sonra güncel sürümü aynı ayrılmış veritabanında çalıştırır; kimlik, ilişki, ad, fiyat, birim ve seçim verilerini karşılaştırır. Eski dosya güvenilen Git commit'inden alınmalı ve derleme çıktılarında tutulmalıdır; ikinci bir seed kopyası repoya eklenmez. SQLCMD için `-I` kullanılır; filtreli indekslerin gerektirdiği `QUOTED_IDENTIFIER` ayarı etkin olur.

## Yönetim ve yetkilendirme entegrasyonu

Kategori, ürün tipi, hizmet ve ürün/hizmet çifti yazmaları gerçek JWT doğrulaması ve veritabanındaki GLOBAL `catalog.manage` izniyle sınırlandırılır. Anonim istek `401`, müşteri ve dükkân/şirket rolleri `403` alır. PlatformAdmin oluşturma, güncelleme ve silme işlemlerini yapabilir. Kodlar ve mevcut çift kimlikleri değiştirilemez. Ayrıntılar [yetkilendirme belgesindedir](CATALOG-AUTHORIZATION.md).

Yerel doğrulama Identity, Operations ve ortak sözleşme testlerini de çalıştırır. Giriş/token üretimi ve refresh uçları ayrı #13 kapsamındadır. Bu çalışma ağacında istemci projesi bulunmadığından istemci testi çalıştırılmaz. Gerçek çalıştırma sonuçları ve sınırlar [doğrulama raporunda](CATALOG-VERIFICATION.md) kaydedilir.

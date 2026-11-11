# Dükkân hizmetleri ve fiyat tarifesi (#17)

Bütün uçlar `/corporates/{corporateId}/stores/{storeId}/offerings` altında,
kimlik doğrulaması ve `store.offering.manage` izniyle çalışır. Şirket ve dükkân
kapsamları hem HTTP policy hem uygulama servisinde kontrol edilir. Yazmalarda yetki,
aynı bağlantı ve Serializable transaction içinde Identity üzerinden yeniden doğrulanır.
Yetkiyi sağlayan kullanıcı/rol/izin/atama kayıtları commit veya rollback sonuna kadar
korunur. Ön kontrolden sonra tamamlanan iptal 403 döndürür; transaction içindeki
kontrolden sonraki iptal ise yazmanın tamamlanmasını bekler. Aynı dükkânın yazmaları,
ortak kapsam kilitlerinin yükseltilmesinde deadlock oluşmaması için önce sıraya alınır.

| İşlem | Yol | Gövde / sonuç |
| --- | --- | --- |
| GET | kök | `page=1&pageSize=20`; en çok 100 kayıt, pasif offering kayıtları dahil |
| PUT | `/{combinationId}` | `{"isActive":true,"priceOverride":null}`; oluşturur veya aynı kaydı günceller |
| PATCH | `/{combinationId}/active` | `{"isActive":false}`; yalnız aktifliği değiştirir |
| PATCH | `/{combinationId}/price` | `{"priceOverride":150.50}`; yalnız fiyatı değiştirir |

`combinationId`, platformdaki `product_type_services.id` değeridir. İstemci yeni
hizmet, para birimi veya fiyat birimi oluşturamaz. Fiyat ve aktiflik alanları
istekte açıkça bulunmalıdır; `priceOverride:null` platform fiyatına dönüş demektir.
Fiyat 0–9999999999,99 arasında ve en çok iki ondalık basamaklıdır.

Liste `{ items, page, pageSize, totalCount }` biçimindedir. Taşan sayfada items boş olsa da toplam kayıt sayısı korunur. Her offering için ID, kombinasyon ID, override, platform fiyatı, etkin
birim fiyat, platform para birimi/fiyat birimi ve offering aktifliğini döndürür.
Liste yönetim görünümüdür; müşteriye görünürlük için `IStoreCatalogReader` kullanılır.

Yazma için şirket/dükkân aktif olmalıdır. Oluşturma, etkinleştirme ve fiyat değişimi
aktif kategori/ürün/hizmet/kombinasyon gerektirir. Platform kombinasyonu kapansa da
mevcut offering pasifleştirilebilir. PATCH bulunmayan offering oluşturmaz (404).
PUT aynı dükkân–kombinasyon kaydını tekrar kullanır; soft delete edilmiş kayıt
aynı ID ile geri açılır. Transaction ve kilitler eşzamanlı PUT isteklerinde çift
kayıt oluşmasını önler. Sipariş ve teklif snapshot tablolarına yazılmaz.

Geçersiz gövde/fiyat 400, oturumsuz istek 401, yetki/kapsam ihlali 403,
bulunmayan veya kullanılabilir olmayan kombinasyon 404 döndürür.
Pasif şirket/dükkân isteği Identity policy tarafından 403 ile reddedilebilir.

Doğrulama: `scripts/Test-StoreManagementData.ps1` ayrılmış SQL Server 2022 LocalDB
veritabanına DACPAC'i iki kez yayınlar ve tüm modül/API/sözleşme testlerini çalıştırır.
Offering testleri fiyat dönüşü, pasiflik zinciri, başka dükkân erişimi, eşzamanlı
oluşturma ve geçmiş `order_item_services` / `price_quote_lines` fiyatlarını kapsar.

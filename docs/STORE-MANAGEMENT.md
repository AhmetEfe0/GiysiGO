# Şirkete bağlı dükkân yönetimi — #14

Bu çalışma #10'un `7dc8764` commit'inden açılan `codex/catalog-store-management` branch'indedir. #11 değişikliklerini içermez. #10 merge edilmeden ana dala yönelik bağımsız fark olarak değerlendirilmemelidir; bağımlılık birleşince başlangıç ve entegrasyon yeniden kontrol edilir.

## HTTP ve yetki

| İşlem | Uç | Gereken izin |
| --- | --- | --- |
| Şirketin dükkânlarını listele | `GET /corporates/{corporateId}/stores` | Şirket kapsamında `store.view` |
| Dükkânı oku | `GET /corporates/{corporateId}/stores/{id}` | Şirket veya gerçek dükkân kapsamında `store.view` |
| Dükkân oluştur | `POST /corporates/{corporateId}/stores` | Şirket kapsamında `store.manage` |
| Bilgileri güncelle | `PUT /corporates/{corporateId}/stores/{id}` | Şirket kapsamında `store.manage` |
| Pasifleştir / yeniden aç | `PATCH /corporates/{corporateId}/stores/{id}/active` | Şirket kapsamında `store.manage` |

`store.manage`, yalnız GLOBAL PlatformAdmin ve CORPORATE CorporateOwner rollerine eklenir. StoreManager/StoreStaff ve Customer bu izni almaz. Şirket sahibi birden fazla fiziksel dükkân yönetebilir. Personel şirketin tüm şubelerini listeleyemez; atanmış aktif dükkânın ayrıntısını okuyabilir. Personel atamalarını sağlayan panel akışı #15 kapsamındadır.

Aktör kimliği `ICurrentUser`, aktiflik/üyelik/atama ve izin kararı gerçek Identity `IPermissionChecker` ile alınır. Gövdeden aktör, şirket, kayıt kimliği veya rol kabul edilmez. URL'deki şirket kimliği tek başına yetki vermez. Yönetim rotasında `{id}` adı bilinçlidir: şirket yetkisiyle pasif dükkân yeniden açılabilir; servis ve SQL komutu gerçek şirket/dükkân eşleşmesini ayrıca denetler. Yanlış şirkete ait dükkân kendi şirket rotasından güncellenmek istenirse 404, yetkisiz şirket rotasına erişilirse 403 döner.

Şirket aidiyeti değiştirilemez. PUT yalnız ad, adres, konum ve yarıçapı değiştirir. Aktiflik ayrı komuttur; aynı aktifliğin tekrarı no-op'tur. Oluşturulan dükkân aktiftir; kimliği sunucuda üretilir. POST her çağrıda yeni fiziksel dükkân oluşturur; otomatik tekrar anahtarı tanımlanmamıştır. İstemci belirsiz ağ sonucunda POST'u körlemesine tekrarlamamalıdır.

Listeler `page=1`, `pageSize=20`, üst sınır 100 ve `{ items, page, pageSize, totalCount }` kullanır. `includeInactive=false` varsayılandır; şirket yöneticisi `true` ile pasif dükkânlarını da görür. Sayfa ve toplam aynı filtrelenmiş geçici tablodan alınır; sıralama ad ve GUID ile kararlıdır. Silinmiş dükkânlar ve pasif/silinmiş şirketlerin dükkânları sunulmaz.

## Veri ve birimler

- Ad: 1–200, adres: 1–2000 UTF-16 karakter; baş/son boşlukları temizlenir. Boş/yalnız boşluk kabul edilmez.
- Enlem: `[-90,90]`, boylam: `[-180,180]`, derece ve en fazla altı ondalık basamak. WGS84 enlem/boylam sırası kullanılır.
- `serviceRadiusKm`: kilometre, `0.01–99999.99`, en fazla iki ondalık basamak. Üst sınır mevcut `decimal(7,2)` şemasının kapasitesidir; yeni bir ticari yarıçap üst sınırı kararı verilmemiştir.
- Konum kapsaması ortak sözleşmeye uygun Haversine büyük çember hesabıdır; dünya yarıçapı 6371 km, sınır dahildir. Enlem/boylam karıştırılmaz; sessiz ölçü yuvarlamasıyla kayıt kabul edilmez.
- **Onaylanan MVP kararı — 9 Kasım 2026:** Hizmet alanı şimdilik kuş uçuşu mesafeyle hesaplanacak; mevcut kod korunacak. MVP sonrasında geliştirmeye devam edilirken kesin kapsama kontrolü yol mesafesine geçirilecek. Rota sağlayıcısı, araç/yön tercihi, kullanım maliyeti ve rota hesaplanamadığında uygulanacak davranış o aşamada kararlaştırılacak. Mevcut kilometre değeri müşteriye veya dükkâna yol mesafesi olarak sunulmayacak.
- Eksik koordinat/yarıçap ve aktiflik JSON alanları reddedilir. İstek şemalarında bilinmeyen alanlar kabul edilmez. Ondalık doğrulaması Türkçe/İngilizce bölgesel ayardan bağımsızdır.
- `create_date/update_date` UTC'dir. İş saatleri bu tabloda bulunmaz. İleride çalışma saatleri eklenirse dükkânın yerel saatleri ve IANA saat dilimi kimliği birlikte modellenmelidir; yalnız UTC saat saklamak yaz/kış saati ve yerel haftalık takvimi karşılamaz. #14 kapsamında saat dilimi veya mesai saati uydurulmadı.

## Public okuyucular ve modül sınırı

Catalog, gerçek `IStoreScopeReader` uygulamasını DI'a kaydeder. Verilen açık bağlantı ve ona ait transaction kullanılır; başka bağlantı açılmaz. Pasif/silinmiş şirket veya silinmiş dükkânda null; pasif dükkânda `IsActive=false` döner. Identity checker/atama authorizer bu kapsamı reddeder. Şirket/dükkân uyuşmazlığı gerçek okuyucuyla test edilir.

`IStoreCatalogReader` ve `ITransactionalStoreCatalogReader` aynı `StoreCatalogReader` uygulamasına kayıtlıdır. `GetStoreLocationAsync` yalnız aktif şirket/aktif dükkân döndürür; bulunamayan/pasif/silinmiş kaynak null, hizmet alanı kontrolü false verir. Transaction alan metotlar verilen transaction'ı commit/rollback/dispose etmez. Boş GUID veya geçersiz koordinat ArgumentException, iptal ve DB hatası çağırana taşınır; altyapı hatası false/null'a dönüştürülmez.

Mevcut public arayüzlerin tamamını kullanılabilir sunmak için `GetOfferingAsync` ve `ServesLocationAsync` de uygulanmıştır; boş veya hata fırlatan üretim yer tutucusu yoktur. Fiyat okuyucusu aktif şirket/dükkân/offering/kategori/ürün/hizmet/çift zincirini arar; fiyat override varsa onu, yoksa çiftin varsayılan fiyatını döndürür. Bu, #21'in dükkân offering yönetimi veya müşteri keşif HTTP ekranlarının tamamlandığı anlamına gelmez; onlar ayrı teslimdir.

Ortak `catalog.v_VisibleStores` görünümü aktif/silinmemiş şirket ve silinmemiş dükkân filtresini altı okuma prosedüründe tekrar yazmayı önler. Müşteri okuyucuları ayrıca dükkânın aktifliğini arar; yönetim okumaları pasif dükkânı gösterebilir. Yazma prosedürü fiziksel tabloları transaction/UPDLOCK/HOLDLOCK ile denetler; şirket aidiyeti koruması SQL tarafında da vardır.

## Hatalar, seed ve teslim sınırları

### Aktiflik ve yoğunluk için karar bekleyen öneriler — 9 Kasım 2026

**Kullanıcının MVP kapsam kararı:** Açık sipariş varken dükkânın pasifleştirilmesini engelleyen ek kontrol bu MVP'ye eklenmeyecek. MVP sonrasında gerekliliği ve kapsamı yeniden kararlaştırılacak; henüz bir çözüm seçilmedi. Değerlendirilecek seçenek: tüm açık siparişler yerine, açık siparişin acil/ekspres olması pasifleştirmeyi engelleyen kriter olabilir. Bu seçenek kabul edilmiş bir iş kuralı değildir. Mevcut kod açık sipariş kontrolü yapmaz, pasif dükkânın personel kapsamını kapatır ve otomatik mesai sonu/tatil geçişi uygulamaz.

Kullanıcı, aşağıdaki ayrımların karar görüşmesinde korunmasını istedi. Bunlar kabul edilmiş veya koda uygulanmış yeni iş kuralları değildir:

| Durum | Görüşülecek öneri |
| --- | --- |
| Mesai dışında | Çalışma takvimiyle yönetme |
| Tatil / tadilat | Yeni siparişleri durdurma; mevcut sipariş ve teslim/iade erişimini koruma |
| Yoğunluk | Kullanıcının önerisi: normal kuru temizleme/terzi siparişlerini açık tutup yalnız acil/ekspres kabulünü kapatma |
| Platform engeli | Şirket sahibinin tek başına kaldıramayacağı ayrı idari engel |
| Kalıcı kapanış | Yeni işi kapatma; geçmişi ve kalan ürünlerin teslim/iade sürecini koruma |

Ana ticari Word belgesi ekspres işlem ve 24 saat/aynı gün teslimi sayar. Mevcut MVP şeması müşteriden alım aralığını ve kurye görevlerinin taşıma aralıklarını saklar; siparişe vaat edilen hazır olma/teslim tarihi ve normal/ekspres süre politikası tanımlı değildir. Teklifin expires_at alanı teklifin kabul süresidir. Yoğunluk önerisi uygulanmadan önce 24 saatin başlangıcı, aynı gün kesim saati, çalışma/tatil günleri, birden fazla hizmetin süre hesabı ve kabul edilmiş siparişlerin korunması kararlaştırılmalıdır. #14 aktiflik alanı bu kararlar alınmadan tatil veya ekspres-kabul anahtarına dönüştürülmez.

400 doğrulama, 401 kimliksiz, 403 izinsiz, 404 şirket kapsamında bulunamayan dükkân, 409 veri durumu çatışması; beklenmeyen hatalar güvenli 500'dür. Problem Details yedi ortak alanı ve 400 için errors alanını taşır. SQL iç ayrıntıları istemciye verilmez.

`StoreManagementPermissionsSeed.sql` yalnız #14 iznini/eşleşmelerini atomik ekler; mevcut kimlikleri, pasif izni ve iptal edilmiş eşleşmeleri değiştirmez. #10'un `IdentitySeed.sql` dosyası değiştirilmedi. Oradaki hata atomikliği bulgusu kapatma öncesi [zorunlu doğrulama takibinde](STORE-MANAGEMENT-VERIFICATION.md) açıktır.

API host'un gerçek JWT bağlaması #13'ün teslimidir. #14 HTTP testlerinde yalnız authentication test şemasıdır; gerçek Identity checker/repository, SQL prosedürleri ve Catalog okuyucuları değiştirilmez. Bu sonuç giriş/refresh/JWT üretiminin veya tüm MVP'nin uçtan uca tamamlandığı iddiası değildir. Flutter/React istemci projesi bu branch'te bulunmaz; ekran testi yapılmış sayılmaz.

Çalıştırma: `pwsh -NoProfile -File scripts/Test-StoreManagementData.ps1`. Script SSDT araçlarını doğrular, ayrılmış SQL 2022 örneğinde DACPAC'i iki kez yayımlar, altı test paketinin TRX sonuçlarını yazar ve yalnız kendi veritabanı/örneğini temizler. Ana dala merge, GitHub yorumu, commit ve push kullanıcı onayı bekler.

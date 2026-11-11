# Şirkete bağlı dükkân yönetimi — #14

Bu çalışma `codex/catalog-store-management` branch'indedir. #10 / PR #46 ve #13 / PR #47 ana dala birleşti; çalışma `main` commit `a0639da` ile uyumlandırıldı. PR hedefi `main`dir.

## HTTP ve yetki

Koordinat ve yarıçap JSON alanları sayı olmalıdır. Ondalık dönüşümde değer kaybı olan girdiler 400 ile reddedilir; örneğin `90.00000000000000000000000000001` değeri 90'a, `1e-100` değeri sıfıra yuvarlanarak kabul edilmez. Tam temsil edilebilen bilimsel gösterim ve sondaki sıfırlar desteklenir. Ardından mevcut aralık ve basamak kontrolleri uygulanır.

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

Catalog, gerçek `IStoreScopeReader` uygulamasını DI'a kaydeder. Verilen açık bağlantı ve ona ait transaction kullanılır; başka bağlantı açılmaz. Yalnız silinmiş/yok dükkânda null; pasif dükkânda `IsActive=false` döner. Şirket pasif veya silinmiş olsa da silinmemiş dükkânın gerçek şirketi döndürülür. Şirket aktifliğini Identity checker/atama authorizer kendi yetki kararında değerlendirir.

`IStoreCatalogReader` ve `ITransactionalStoreCatalogReader` aynı `StoreCatalogReader` uygulamasına kayıtlıdır. `GetStoreLocationAsync` yalnız aktif şirket/aktif dükkân döndürür; bulunamayan/pasif/silinmiş kaynak null, hizmet alanı kontrolü false verir. Transaction alan metotlar verilen transaction'ı commit/rollback/dispose etmez. Boş GUID veya geçersiz koordinat ArgumentException, iptal ve DB hatası çağırana taşınır; altyapı hatası false/null'a dönüştürülmez.

Mevcut public arayüzlerin tamamını kullanılabilir sunmak için `GetOfferingAsync` ve `ServesLocationAsync` de uygulanmıştır; boş veya hata fırlatan üretim yer tutucusu yoktur. Fiyat okuyucusu aktif şirket/dükkân/offering/kategori/ürün/hizmet/çift zincirini arar; fiyat override varsa onu, yoksa çiftin varsayılan fiyatını döndürür. Bu, #21'in dükkân offering yönetimi veya müşteri keşif HTTP ekranlarının tamamlandığı anlamına gelmez; onlar ayrı teslimdir.

Ortak `catalog.v_VisibleStores` görünümü yalnız Catalog'un silinmemiş dükkânlarını kapsar; Identity tablosunu okumaz. Catalog müşteri ve yönetim okuyucuları şirket aktifliğini Identity'nin `ICorporateStatusReader` sözleşmesiyle denetler. Sağlayıcı `identity.spIsCorporateActive` prosedürünü çağırır ve aynı bağlantı/transaction içinde aktif/silinmemiş şirketi doğrular. Şirket satırındaki paylaşım kilidi transaction sonuna kadar tutulur; okuma veya yazma kararı sırasında şirketin pasifleştirilmesiyle yarışılmaz. Yönetim repository'si ve müşteri okuyucuları işlemi aynı transaction'da sürdürür. Yazma prosedürü yalnız Catalog verisini ve şirket/dükkân aidiyetini transaction/UPDLOCK/HOLDLOCK ile denetler. Şirket kontrolü gerektiren tüketici doğrudan Catalog prosedürünü çağırmak yerine bu public okuyucu veya yönetim servisini kullanmalıdır.

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

`store.manage` yalnız ortak `generate-identity-permission-seed.mjs` üreticisinden `IdentityPermissionsSeed.sql` içine üretilir; ayrı #14 seed'i yoktur. Sabit izin GUID'i `8b314bca-963a-5231-b7d0-768947eebe68`; yalnız PlatformAdmin ve CorporateOwner eşleşmeleri vardır. Tekrar, pasif izin ve iptal edilmiş eşleşmeler korunur. `--check` seçeneği üretilmiş dosyanın kaynakla uyuşmasını denetler; doğrulama script'i DACPAC derlemeden önce bu kontrolü yapar. #10 testleri artık kendi hazırlığını transaction içinde yapıp geri alır; #14 script'inde eski hazırlık çağrısı bulunmaz.

Eski #14 seed'inin rastgele kimlikle oluşturduğu izin, yalnız tanınan eski açıklamasıyla bulunduğunda aynı transaction içinde sabit GUID'e taşınır. İznin aktiflik/silinme/tarih bilgileri ve grant kimlikleri/tarihleri korunur; referanslar yeni izin kimliğine bağlanır. Tanınmayan bir kimlik uyuşmazlığı veya hedef GUID'in başka kayda ait olması 52100 ile durur. Sonraki seed adımında hata olursa geçiş de geri alınır. Bu özel yükseltme, diğer sabit rol/izin kimliklerinin uyuşmazlık kontrollerini gevşetmez.

API host'unda #11 ile gelen JWT doğrulaması korunur. #14 HTTP testleri gerçek Identity checker/repository, SQL prosedürleri ve Catalog okuyucularını kullanır. Yönetim senaryolarında authentication test şeması, `StoreJwtTests` içinde ise gerçek JWT doğrulaması kullanılır. JWT testi sahip/personel erişimini, pasifleştirme/yeniden açmayı, pasif kullanıcıyı ve yanlış imzayı kapsar. Giriş/refresh/token üretimi #13 kapsamındadır. Flutter/React istemci projesi bu branch'te bulunmaz; ekran testi yapılmış sayılmaz.

Çalıştırma: `pwsh -NoProfile -File scripts/Test-StoreManagementData.ps1`. Script ortak seed üretimini ve SSDT araçlarını doğrular, ayrılmış SQL 2022 örneğinde DACPAC'i iki kez yayımlar, altı test paketinin TRX sonuçlarını yazar ve yalnız kendi veritabanı/örneğini temizler. #10 birleşmiştir; #14 son test ve yeniden inceleme onayından sonra birleştirilir.

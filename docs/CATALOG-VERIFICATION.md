# Katalog #11 doğrulama raporu

Tarih: 24 Ekim 2026. Branch: `feature/catalog-models-repo`. Kontroller OneDrive içindeki GiysiGO çalışma ağacında yapıldı; Downloads kopyası kullanılmadı. İlk #11 teslimi `33e8d2f` ile pushlandı; bu rapordaki seed sadeleştirmesi onu izleyen ayrı bir düzenlemedir. Merge yapılmadı.

## Değişiklikler

- Kullanıcının 16 terzi kalemi kararı [karar belgesine](CATALOG-DECISIONS.md) ve `catalog-decisions.json` dosyasına işlendi. 14 kalem 24 mevcut çifte eşlendi; 2 kalem kapsam dışında kaldı. Mevcut fiyatlar korundu.
- Seed 5 kategori, 48 ürün, 121 hizmet ve 158 aktif ürün/hizmet çifti içeriyor. GUID değerleri sabit kaynak kodlarından türetiliyor; başlangıçta seçili hizmet yok.
- Perde tadilatlarının üçü M2; P037/S099 aktif ek hizmet; P039/S102 kapsam dışı; P044/S112 aktif alternatif.
- Seed tekrarında mevcut kimlikler ve ilişkiler korunuyor. Kapsam dışı bir çift önceki dağıtımda aktif kaldıysa pasifleştiriliyor.
- HTTP katalog okumaları DTO döndürüyor. Ürün/hizmet okumaları geçerli aktif ilişkilerle sınırlı.
- `ordering.spCheckoutCart` her üründe en az bir BASE veya ALTERNATIVE arıyor. Boş seçim ve yalnız ek hizmet seçimi reddediliyor.
- Platform yönetimi için dört kaynağın oluşturma/güncelleme/silme uçları eklendi. Gerçek JWT doğrulaması, aktif kullanıcı denetimi ve SQL tabanlı `catalog.manage` izni uygulanıyor. Müşteri, dükkân personeli ve şirket sahibi platform kataloğuna yazamıyor. Ayrıntılar [yetkilendirme belgesindedir](CATALOG-AUTHORIZATION.md).
- Yeni karar belgeleri, açıklamalar, SQL yorumları ve eklenen hata mesajları Türkçedir. Kod tanımlayıcıları ve teknik sabitler mevcut adlarını korur.

## Çalıştırılan kontroller

`scripts/Test-CatalogData.ps1` kurulu Visual Studio araçlarını `vswhere` ile buldu; kalıcı PATH değişikliği yapılmadı. MSBuild/SSDT ile Release DACPAC derlendi. Rastgele adla oluşturulan, bu çalıştırmaya özel LocalDB örneğine DACPAC yüklendi. Testlerden sonra test veritabanı ve bu örnek temizlendi.

| Kontrol | Sonuç |
| --- | --- |
| DACPAC Release derlemesi ve ayrılmış LocalDB'ye yükleme | Başarılı |
| Catalog testleri | 9 geçti, 0 başarısız, 0 atlandı |
| HTTP/API testleri | 20 geçti, 0 başarısız, 0 atlandı |
| Identity testleri | 11 geçti, 0 başarısız, 0 atlandı |
| Ordering testleri | 9 geçti, 0 başarısız, 0 atlandı |
| Operations testleri | 1 geçti, 0 başarısız, 0 atlandı |
| Ortak sözleşme testleri | 19 geçti, 0 başarısız, 0 atlandı |
| Toplam | 69 geçti, 0 başarısız, 0 atlandı |
| Seed dosyasını yeniden üretme | SHA256 değeri değişmedi |
| `git diff --check` | Hata yok |

İlk tur SQL Server 2019 LocalDB (`15.0.4382.1`) üzerinde yapılmıştı. Kullanıcının talebiyle SQL Server 2022 LocalDB (`16.0.1000.6`) Microsoft imzalı paketle yan yana kuruldu ve tam tur 2022 üzerinde tekrarlandı. DACPAC hedefi SQL Server 2022'dir. Nihai yüklemede `AllowIncompatiblePlatform=false` kullanıldı; sunucunun `ProductMajorVersion=16` değeri bağlantı üzerinden doğrulandı. Böylece hedef sürüm ile çalışma zamanı sürümü arasındaki önceki doğrulama açığı giderildi. Testler ayrılmış LocalDB/Express motorundadır; üretim sunucusunun yapılandırması veya yük testi kapsamı değildir.

## Test kanıtları

- `tests/Modules/Catalog/IntegrationTests/CatalogSeedSqlServerTests.cs`: seed iki kez çalışır; kimlik, ilişki, fiyat ve seçim bilgilerinin aynı kaldığı karşılaştırılır. Önceden aktif kalan kapsam dışı çiftin pasifleştirildiği doğrulanır.
- `tests/Modules/Catalog/IntegrationTests/VerifyCatalogSeed.sql`: kaynak kayıt sayıları, M2 birimleri, başlangıç seçimleri, battaniye ek hizmeti ve yastık alternatifi gerçek SQL üzerinde denetlenir.
- `tests/Modules/Catalog/IntegrationTests/VerifyPrimarySelection.sql`: gerçek checkout prosedürü boş seçim ve yalnız ek hizmet için hata verir; hem BASE hem ALTERNATIVE senaryosu ek hizmetle birlikte sipariş oluşturur. Test verileri geri alınır.
- `tests/API/GiysiGo.API.IntegrationTests/CatalogHttpTests.cs`: gerçek HTTP ve SQL okumaları, geçerli ürün/hizmet çiftleri, kapsam dışı satırın görünmemesi, 404/400 davranışları ve anonim yazmanın 401 ile reddedilmesi sınanır. Hata enjeksiyonu testi 500 yanıtında iç ayrıntının sızmadığını ve takip kimliği verildiğini denetler.
- `tests/API/GiysiGo.API.IntegrationTests/CatalogAuthorizationTests.cs`: gerçek imzalı JWT ve SQL permission sağlayıcısıyla müşteri/personel/şirket sahibi için 403; sahte rol/izin/kimlik iddiaları; hatalı veya süresi dolmuş token için 401; rol iptali, kullanıcı pasifliği ve şirket/dükkân kapsam sınırları sınanır.
- `tests/API/GiysiGo.API.IntegrationTests/CatalogManagementTests.cs`: yetkili yöneticinin dört kaynak için yazma akışı; sabit kod/çift kimliği; yinelenen kayıt ve durum çatışması 409; hatalı veri 400; eksik ebeveyn 404; pasif kayıtların müşteri seçiminden çıkarılması sınanır.
- `tests/Modules/Catalog/IntegrationTests/VerifyIdentityPermissionsSeed.sql` ve `VerifySeedRevocations.sql`: rol/izin seed tekrarı, sabit kimlikler ve iptal edilmiş izinlerin yeniden açılmaması denetlenir.
- `.github/workflows/ci.yml`: SQL işi Catalog testlerinin yanında gerçek katalog HTTP testlerini ve Ordering SQL regresyonlarını da çalıştıracak şekilde güncellendi. Bu yerel değişiklik için uzak CI henüz çalıştırılmadı.

## Kabul ölçütleri ve kapsam

| Ölçüt | Sonuç ve kanıt |
| --- | --- |
| Tekrar seed kayıtları çoğaltmaz; sabit kod/GUID ilişkileri korunur | Gerçek SQL üzerinde iki çalıştırma karşılaştırıldı; CatalogSeedSqlServerTests |
| Dükkân platform kategori/ürün/hizmeti oluşturamaz | Tüm 12 yazma ucu müşteri/personel/şirket sahibi için 403; CatalogAuthorizationTests |
| Belirsiz fiyat/birim satırları aktif sunulmaz | Kararlar kaynakla karşılaştırıldı, kapsam dışı çift pasifleştirildi ve HTTP sonucunda bulunmadı |
| Ürüne yalnız geçerli hizmetler gelir | Etkin kategori/ürün/hizmet/çift filtreleri; CatalogHttpTests ve CatalogManagementTests |
| Değişen seçim kuralı ve hata/tekrar/yetki sınırları doğrulandı | Checkout SQL, seed tekrarı, gerçek JWT/HTTP ve kapsam testleri geçti |
| İlgili .NET ve DACPAC kontrolleri | Yukarıdaki altı test paketi ve DACPAC derleme/yükleme başarılı |
| İstemci kontrolleri | Uygulanamaz: çalışma ağacında apps, package.json veya pubspec.yaml bulunmuyor; GitHub ana dal kod aramasında da istemci manifesti bulunmadı. Açık #18 ve #22 uygulamaların henüz oluşturulmadığını belirtiyor. Mevcut olmayan istemci için test sonucu üretilmedi |

#11'in bu çalışma ağacındaki backend kabul ölçütleri incelemeye hazırdır. Giriş, token üretimi, refresh ve çıkış ayrı #13 kapsamındadır. Üretim JWT ayarları ve ilk yönetici ataması yetkilendirme belgesindeki şekilde hazırlanmalıdır. Bu sonuç tüm uygulamanın hatasız olduğuna dair bir garanti değildir; listelenen testlerle doğrulanan kapsamı ifade eder.

Nihai SQL 2022 günlüğü `database/GiysiGo.Database/bin/Release/catalog-seed-compaction.log`, altı TRX sonucu aynı klasörün `CatalogVerification/` altındadır. Önceki SQL 2022 günlükleri `catalog-sql2022-final-review.log` ve `catalog-sql2022-verification.log`, SQL 2019 günlüğü `catalog-security-final.log` olarak korunur. Bunlar yerel derleme çıktılarıdır. İlk hata enjeksiyonu denemesinde Windows EventLog yazma izni nedeniyle test altyapısı başarısız oldu; yalnız o test host'unda günlük sağlayıcıları kaldırıldı. Ardından ilgili iki test ve nihai tam tur yeniden çalıştırıldı. Bu rapordaki sonuçlar yerel doğrulamalardır; uzak CI sonucu olarak sunulmaz.

İstemci durumunun GitHub kanıtları: [Flutter uygulaması #18](https://github.com/DOU-SEProjects/GiysiGO/issues/18), [React paneli #22](https://github.com/DOU-SEProjects/GiysiGO/issues/22). İkisi de ayrı M4 geliştirme işidir; #11 mevcut backend seed/API kapsamındadır. Bu kontrolde istemci uygulaması oluşturulmadı; mevcut API tüketimi gerçek HTTP testleriyle doğrulandı.

## Push öncesi ek inceleme

Kullanıcının kapsam kararı: #11'in mevcut teslimi doğrulanır; diğer sahiplerin açık modül işleri bu teslimata eklenmez. Tüm MVP'nin tamamlandığı veya bütün modüllerin uçtan uca çalıştığı onayı verilmez.

- Fiyat JSON alanı gönderilmediğinde varsayılan `0` kullanılmasını önlemek için `defaultPrice` zorunlu yapıldı. Açıkça gönderilmiş sıfır fiyat mevcut kurala göre geçerlidir. Gerçek JWT/HTTP testi eksik fiyatın `400` aldığını denetler.
- Ürünün hizmet listesinde ilk sayfada kesilme giderildi. 125 ek hizmetle, birden fazla sayfadaki 127 geçerli seçeneğin tamamının döndüğü test edildi.
- Ürün detayı ve hizmet listesi, kategori yoksa veya pasifse `404` verir; iki durum da test edildi.
- Ordering servisleri hâlen `ICustomerAddressReader` (#16) ve `IStoreCatalogReader` (#21) sağlayıcılarını bekliyor. İlgili DI girişlerinde bu sağlayıcılar yoktur; health kontrolünün geçmesi bu servislerin kullanılabildiği anlamına gelmez.
- Operations kaydı boştur; olay işleyicisi ve otomatik outbox worker yoktur. Dispatcher altyapısı vardır; siparişten kurye/teslimata kadar otomatik akışın tamamlandığı iddia edilmez. Bunlar `MODULE-CONTRACTS.md` ve `SHARED-START.md` içinde ayrı teslimler olarak tanımlıdır.
- Giriş/refresh/çıkış ve Flutter/React istemcileri önceki kapsam sınırlarıyla aynıdır.
- `dotnet build GiysiGo.sln` denemesi, klasik SSDT SQL projesinin dotnet CLI tarafından yüklenememesi nedeniyle `MSB4278` verdi. C# projeleri ilgili test komutlarıyla, SQL projesi Visual Studio MSBuild/SSDT ile doğrulanır; doğru iki araçla yapılan kontroller yukarıdadır. Bu araç sınırı uygulama testi hatası olarak gizlenmedi.

## Seed sadeleştirmesi — 24 Ekim 2026

- `CatalogSeed.sql` 5.800 satırdan 431 satıra indi (yaklaşık %93 azalma). Tekrarlanan kayıt başına SQL blokları yerine tek satırlık veri kayıtları ve tablo başına ortak `UPDATE`/`INSERT` sorguları kullanılır. Kaynak JSON, kullanıcı kararları, UUIDv5 ad alanı ve GUID üretimi değişmedi.
- Üretici doğrulamaları `generate-catalog-seed.mjs` içinde, veri tabloları ve ortak SQL mantığı `catalog-seed-sql.mjs` içindedir. Her VALUES grubu SQL Server'ın 1.000 satırlık sınırına uygun bölünür.
- `.gitattributes`, katalog ve Identity seed dosyalarını `linguist-generated=true` ile işaretler. GitHub'da üretilen SQL daraltılabilir; kaynaklar ve üretim mantığı incelemeye açıktır. Dosyalar DACPAC'e dahil olmaya devam eder.
- Eski seed, Git'teki `33e8d2f` commit'inden derleme klasörüne alındı. `Test-CatalogData.ps1 -BaselineCatalogSeedPath ...` ile aynı ayrılmış SQL 2022 veritabanında eski/yeni sonuçlar karşılaştırıldı: kategori/ürün/hizmet adları, sıralama, kod/GUID ilişkileri, fiyatlar, birimler ve seçim türleri birebir eşleşti.
- `Seed_rejects_changed_stable_ids_without_partial_updates` kategori, ürün, hizmet ve çift için ayrı GUID uyuşmazlıklarını dener. Her deneme `51020` verir; önceki veri korunur ve açık transaction kalmaz.
- Mevcut tekrar testi, `DisturbCatalogSeed.sql` ile değiştirilen ad/fiyat/birim/seçim ve pasif/silinmiş durumların yeniden düzeltildiğini de doğrular. Kapsam dışı çift hâlâ pasifleştirilir.
- İlk eski/yeni karşılaştırması eski seed'in SQLCMD bağlantısında `QUOTED_IDENTIFIER` kapalı olduğu için durdu. Karşılaştırmaya `-I`, yeni seed'e açık SET ayarları eklendi; eski/yeni karşılaştırması ve test turu yeniden çalıştırıldı.

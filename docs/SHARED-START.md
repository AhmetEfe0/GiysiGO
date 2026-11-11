# Dört modül için ortak başlangıç

## Main durum özeti

21 Ekim 2026 tarihinde `f60442e` main commit'i üzerinden doğrulandı:

- API host, ortak taban sınıflar, dört modülün proje bağlantıları ve DI girişleri var.
- MSSQL projesinde 39 tablo, outbox prosedürleri ve Ordering iş akışı prosedürleri var.
- #5 ortak modül/iş akışı sözleşmeleri ve on bir integration event tipi var.
- #8 Ordering modelleri, Dapper repository'leri, sepet/checkout/teklif/ödeme servisleri
  ve SQL regresyon testleri main'e birleştirildi. SQL testleri ayrılmış SQL Server
  veritabanı sağlandığında çalışır; bağlantı yoksa atlanır.
- Identity JWT/refresh, gerçek permission uygulaması, Catalog ve Operations iş
  akışları ile müşteri/dükkân uygulamaları bu referans commit'te tamamlanmış değil.
- CI API/modül testlerini ve DACPAC derlemesini kontrol eder; tüm uçtan uca iş
  akışlarının tamamlandığı anlamına gelmez.
- Bilinen şema işi: courier_profiles.user_id üzerindeki nullable UNIQUE,
  birden fazla NULL mock kurye kaydını engelliyor. Filtreli benzersiz indeks
  düzeltmesi ve mock seed #12 kapsamındadır; çoklu mock kurye henüz hazır değildir.

Bu tarihli özet, sonraki PR'lar main'e birleştikçe güncellenmelidir.
Belge amaçları ve güncelleme kuralı [dokümantasyon rehberindedir](README.md).

Public sözleşmelerin sahipliği, null/hata/aktiflik ve transaction kuralları
[MODULE-CONTRACTS.md](MODULE-CONTRACTS.md), aktör ve durum geçişleri
[WORKFLOW-CONTRACTS.md](WORKFLOW-CONTRACTS.md) içinde tanımlıdır. HTTP örnekleri
[OpenAPI sözleşmesindedir](openapi/mvp-contracts.json). Bunlar #5 tasarım temelidir;
her modül gerçek implementasyonunu kendi issue'sunda teslim eder.

## Modül sahipliği

| Modül | Sahip | C# alanı | SQL alanı | Test projesi |
| --- | --- | --- | --- | --- |
| Identity | @PnterNN | `src/Modules/Identity` | `identity` | `tests/Modules/Identity` |
| Catalog | @sdnrkaleli | `src/Modules/Catalog` | `catalog` | `tests/Modules/Catalog` |
| Ordering | @AhmetEfe0 | `src/Modules/Ordering` | `ordering` | `tests/Modules/Ordering` |
| Operations | @selincellkk | `src/Modules/Operations` | `operations` | `tests/Modules/Operations` |

Her modülde Domain, Application, Infrastructure ve IntegrationEvents projeleri solution'a bağlıdır. Domain kendi varlıklarını, Application iş akışlarını ve public arayüzlerini, Infrastructure Dapper/MSSQL erişimini tutar. API, her modülün `Add*Module` metodunu çağırır. Modül sahibi kendi servis ve handler kayıtlarını bu metoda ekler. Başka modülün Domain veya Infrastructure projesine doğrudan referans verilmez.

Repository kullanan entity'lerin beş temel stored procedure sözleşmesi ve iş akışı tablolarının istisnaları `docs/STORED-PROCEDURE-CONVENTIONS.md` içinde sabitlenmiştir.

## Sabitlenen ortak sözleşmeler

- `ICurrentUser` ve `IPermissionChecker`: Identity sağlar. Sabit permission adları `PermissionCodes` içindedir; Identity seed'i ve diğer modüllerin kontrolleri aynı kodları kullanır. Permission kodu ve isteğin corporate/store kapsamı sunucuda birlikte denetlenir. JWT üretimi/doğrulaması, rollerin seed'i ve gerçek permission uygulaması Identity sahibinin işidir; mevcut API host henüz kullanıcı oturumu açmaz.
- `ICustomerAddressReader`: Identity sağlar; Catalog keşif ve Ordering sepet önizlemesi müşterinin kendine ait adresini okur. Identity #16, aynı SQL transaction'ına katılabilen `ITransactionalCustomerAddressReader` uygulamasını sağlar; Ordering checkout'unun bu okuyucuya geçişi #26 kapsamındadır.
- `IStoreCatalogReader`: Catalog sağlar. Aktif ürün-hizmet teklifini, dükkân konumunu ve koordinata göre hizmet alanını doğrular. Ordering checkout sırasında tekrar çağırır; dönen birim fiyat sipariş satırına kopyalanır.
- `IOrderPickupReader`: Ordering sağlar. Operations, `OrderPlacedEvent` geldiğinde alım görevinin adresini, iletişim bilgisini, ürün kapasitesini ve zaman penceresini okur; varış noktası için Catalog'un dükkân konumunu kullanır.
- On bir olay Ordering ve Operations IntegrationEvents projelerinde tanımlıdır. Eski sekiz olaya kurye atama, taşıma başlangıcı ve ayrı iade tamamlanması eklenmiştir. Olayları başka modülün entity'si yerine kullanın. `EventId` tekrar işleme anahtarıdır. `EventType` sürümlü ve sabittir; yayınlandıktan sonra isim/payload değişikliği yeni sürüm gerektirir.
- `ITransactionRunner` tek SQL bağlantısı ve transaction açar. Çok tablolı iş akışında Dapper komutlarına verilen connection ve transaction aynı olmalıdır. `IOutboxWriter` iş verisiyle **aynı transaction** içinde olay satırını ekler. `RepositoryBase` metotları kendi bağlantısını açtığından bu akışlarda kullanılmaz.

`IOutboxDispatcher.DispatchNextAsync` bir bekleyen olayı kilitler, kayıtlı `IOutboxEventHandler` uygulamalarını çalıştırır ve aynı transaction içinde işlendi olarak işaretler. Handler'lar modül sahiplerince yazılıp DI'ya eklenecek; ardından dağıtıcı bir zamanlayıcı/hosted service ile çağrılacak. Henüz otomatik arka plan çalıştırması yoktur. DB değişiklikleri aynı transaction içinde atomiktir. Harici ödeme gibi transaction dışı etkiler kendi idempotency anahtarını (`EventId`) kullanmalıdır.

## Başlangıç ve doğrulama

Identity #6 veri erişiminin kapsamı, repository davranışları ve ayrı LocalDB ile
gerçek prosedür testleri [IDENTITY-DATA.md](IDENTITY-DATA.md) içinde açıklanır.

```powershell
dotnet test tests/Contracts/GiysiGo.Contracts.Tests.csproj --configuration Release
dotnet test tests/API/GiysiGo.API.IntegrationTests/GiysiGo.API.IntegrationTests.csproj --configuration Release
dotnet test tests/Modules/Identity/GiysiGo.Modules.Identity.Tests.csproj --configuration Release
dotnet test tests/Modules/Catalog/GiysiGo.Modules.Catalog.Tests.csproj --configuration Release
dotnet test tests/Modules/Ordering/GiysiGo.Modules.Ordering.Tests.csproj --configuration Release
dotnet test tests/Modules/Operations/GiysiGo.Modules.Operations.Tests.csproj --configuration Release
```

CI bu projeleri Linux'ta test eder, SSDT SQL projesini Windows'ta DACPAC'e derler. Veritabanı şemasının kaynağı `database/GiysiGo.Database/GiysiGo.Database.sqlproj` içindeki ayrı tablo/prosedür dosyalarıdır. API entegrasyon testi şu anda yalnızca host/health başlangıcını doğrular; gerçek iş akışları geliştikçe modül ve uçtan uca testler eklenir.
SQL projesi modül klasörlerindeki yeni `.sql` dosyalarını otomatik dahil eder; prosedür eklerken ortak `.sqlproj` dosyasını düzenlemeyin.

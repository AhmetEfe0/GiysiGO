# Identity rol ve izin temeli — #10

`Scripts/IdentitySeed.sql`, DACPAC PostDeployment sırasında beş sabit rolü,
`PermissionCodes` içindeki dokuz izni ve varsayılan rol–izin eşleşmelerini kurar.
Tekrar yayınlama aynı rol/izin kodunu veya canlı eşleşmeyi çoğaltmaz. Mevcut
rol/iznin aktiflik durumunu değiştirmez ve kaldırılmış bir rol–izin eşleşmesini
yeniden vermez; yetkili kişinin yaptığı iptal DACPAC yayınında korunur. Customer
personel izni almaz; StoreStaff `quote.prepare` alır fakat `quote.approve` almaz.
Role/permission kodları sabit anahtardır. PlatformAdmin yalnızca kendisine
tanımlı izinleri alır; hangi HTTP işlemine girebileceği ayrıca doğrulanmalıdır.

`IPermissionChecker.HasPermissionAsync` kimliği, izin kodunu ve istenen
corporate/store kapsamını okur. Bilinmeyen veya pasif/silinmiş kullanıcı, izin,
rol, üyelik ve atama için `false` döndürür. Kapsam verilmezse yalnızca GLOBAL
roller değerlendirilir. Store ID verildiğinde `IStoreScopeReader`, mağazanın
aktifliğini ve corporate kimliğini aynı bağlantı/transaction içinde doğrular;
corporate rolü başka mağazaya taşınmaz. Store kapsamı istendiğinde okuyucu DI'da
yoksa yapılandırma hatası fırlatılır; bilinmeyen veya pasif mağaza `false`
döndürür. #10, `IStoreScopeReader` sözleşmesini tüketir. Catalog Infrastructure
içindeki `StoreScopeRepository`, mevcut `catalog.usp_GetStoreById` prosedürünü
çağırıp mağazanın şirket/aktiflik bilgisini aynı bağlantı ve transaction içinde
döndürür; API host'u bu okuyucuyu `AddCatalogModule` ile kaydeder. Yetki testi
gerçek Catalog okuyucusuyla mağaza kapsamını, ayrıca test okuyucusuyla pasif
mağaza durumunu doğrular. Catalog #14/#21 mağaza yönetimi ve tarife okumalarını
bu temel sözleşmenin üstünde tamamlar.

Yetki kararındaki iki amaç-özel SQL prosedürünü `IIdentityAuthorizationRepository`
üzerinden `IdentityAuthorizationRepository` çağırır. `PermissionChecker` ve
`StaffAssignmentAuthorizer` kapsamı/iş kuralını denetler, Dapper çağrısını yapmaz.
Repository, verilen açık bağlantı ve transaction'ı kullanır; `RepositoryBase<TEntity>`
beş CRUD işlemi için olduğundan bu karar okumalarında kullanılmaz.

`IStaffAssignmentAuthorizer.CanManageAsync`, #15'teki personel atama komutunun
rol verme/iptal etme işleminden önce aynı SQL bağlantısı ve transaction içinde
çağrılır. PlatformAdmin aktif bir corporate'a CorporateOwner ve aktif mağazasına
StoreManager/StoreStaff atayabilir. CorporateOwner yalnızca kendi corporate'ının
mağazasına StoreManager/StoreStaff, StoreManager yalnızca kendi mağazasına
StoreStaff atayabilir. Kaynak corporate ID ile mağazanın gerçek corporate ID'si
eşleşmelidir. Aktör kendine rol atayamaz. Pasif kullanıcı, rol, izin, üyelik ve
atamalar karar vermez. Bu denetim rol hiyerarşisini korur; #15'in grant/revoke
komutları kullanıcı girdisini doğrudan erişim repository'sine geçirmemelidir.

`ICurrentUser`, kimliği doğrulanmış isteğin `NameIdentifier` veya `sub`
claim'inden Guid okur. JWT üretimi ve doğrulaması #13'ün işidir. API host,
`PermissionCodes` değerlerini ASP.NET Core authorization policy olarak kaydeder.
Korunan controller action'ı `[Authorize(Policy = PermissionCodes.StoreView)]` gibi
uygun kodu belirtir; `corporateId` ve `storeId` route parametreleri varsa handler
bunları `IPermissionChecker`'a geçirir. Yanlış/boş Guid kapsamı kabul edilmez.
Anonim isteğe 401, doğrulanmış fakat izinsiz isteğe 403; her ikisine `code`,
`traceId`, `instance` içeren Problem Details döner. Body veya kaynak ID'sinden
çözülen kapsamlar komut/okuma servisinde ayrıca denetlenmelidir; yalnızca route
politikası veya UI butonunu gizlemek yetki kanıtı değildir. Personel atama
endpoint'leri #15'te bu temeli ve `IStaffAssignmentAuthorizer`'ı kullanır.

Gerçek MSSQL testi için `./scripts/Test-IdentityData.ps1` DACPAC'i izole
veritabanına iki kez yayınlar. Bu, seed tekrarını, izin eşleşmelerini ve kapsam
okumalarını doğrular. API entegrasyon testi test authentication şeması ve
permission fake'iyle HTTP 401/403/200 ve kapsam aktarımını doğrular. Mevcut
Linux CI bağlantı değişkeni yoksa DB testlerini skipped gösterir; Windows SQL
job'u ayrı LocalDB veritabanında Identity testlerini gerçekten çalıştırır.
#19, JWT/oturum ve tenant izolasyonu için daha geniş gerçek API+DB testlerini
tamamlar. `FixtureStoreScopeReader` yalnızca pasif mağaza gibi kontrollü durumları
test etmek içindir.

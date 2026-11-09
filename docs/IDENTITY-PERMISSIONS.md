# Identity rol ve izin temeli — #10

`Scripts/IdentityPermissionsSeed.sql`, DACPAC PostDeployment sırasında beş sabit rolü,
`PermissionCodes` içindeki on izni ve varsayılan rol–izin eşleşmelerini kurar.
Bu seed #52'nin sabit kimliklerini ve rol matrisini korur; ikinci bir Identity
seed'i çalıştırılmaz. `catalog.manage` yalnız GLOBAL PlatformAdmin rolündedir.
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
döndürür. #10, `IStoreScopeReader` sözleşmesini tüketir. #52'de Catalog sahibinin
eklediği gerçek `StoreScopeReader` ve DI kaydı korunur; Identity bu sağlayıcıyı
kendi repository'si üzerinden verdiği yetki kararıyla birleştirir. Identity MSSQL
testleri kontrollü okuyucuyu, Catalog yetki testleri gerçek sağlayıcıyı kullanır.
Mağaza yönetimi ve tarife contract'larının kalan işleri #14/#21 kapsamındadır.

Yetki kararındaki iki amaç-özel SQL prosedürünü `IIdentityAuthorizationRepository`
üzerinden `IdentityAuthorizationRepository` çağırır. `PermissionChecker` ve
`StaffAssignmentAuthorizer` kapsamı/iş kuralını denetler, Dapper çağrısını yapmaz.
Repository, verilen açık bağlantı ve transaction'ı kullanır. Yetki prosedürü,
store kimliğiyle birlikte corporate kapsamı verilmediğinde erişimi reddeder.
`RepositoryBase<TEntity>` beş CRUD işlemi için olduğundan bu karar okumalarında
kullanılmaz.

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
claim'inden Guid okur. #52'nin JWT doğrulama kaydı korunur; token üretimi ve
oturum/refresh akışı #13'ün işidir. API host,
`PermissionCodes` değerlerini ASP.NET Core authorization policy olarak kaydeder.
Korunan controller action'ı `[Authorize(Policy = PermissionCodes.StoreView)]` gibi
uygun kodu belirtir; `corporateId` ve `storeId` route parametreleri varsa handler
bunları `IPermissionChecker`'a geçirir. Yanlış/boş Guid kapsamı kabul edilmez.
Anonim isteğe 401 ve `authentication_required`, doğrulanmış fakat izinsiz isteğe
403 ve `permission_denied` döner. İki yanıt da ortak Problem Details alanlarını
taşır ve mevcut authentication şemasının Challenge/Forbid davranışını korur.
Body veya kaynak ID'sinden çözülen kapsamlar komut/okuma servisinde ayrıca
denetlenmelidir; yalnızca route
politikası veya UI butonunu gizlemek yetki kanıtı değildir. Personel atama
endpoint'leri #15'te bu temeli ve `IStaffAssignmentAuthorizer`'ı kullanır.

Gerçek MSSQL testi için `./scripts/Test-IdentityData.ps1` DACPAC'i izole
veritabanına iki kez yayınlar. Bu, seed tekrarını, izin eşleşmelerini ve kapsam
okumalarını doğrular. API entegrasyon testi test authentication şeması ve
permission fake'iyle HTTP 401/403/200 ve kapsam aktarımını doğrular. Mevcut
Linux CI bağlantı değişkeni yoksa DB testlerini skipped gösterir; gerçek DB CI
entegrasyonu #19 kapsamındadır. Bu testlerdeki `FixtureStoreScopeReader`, #10'un
Catalog'dan bağımsız geliştirilebilmesi içindir; canlı Catalog verisi okuduğu
iddiası taşımaz.

## #52 sonrasında #46 uyumu

Birleştirme sırası #52 → #46'dır. #52'nin JWT doğrulaması, `catalog.manage`
policy'si ve Catalog sağlayıcısı korunur. Tek `ICurrentUser` ve
`IPermissionChecker` kaydı vardır; amaç-özel Identity prosedürlerini yalnız
`IdentityAuthorizationRepository` çağırır. Katalog yetki testleri ve #10'un
route kapsamı/Challenge/Forbid testleri aynı API host'u üzerinde çalışır.

`./scripts/Test-IdentityData.ps1 -BaselineDacpacPath <PR52.dacpac>` önce #52'nin
izole veritabanını kurar, mevcut kullanıcıya rol atar ve rol/permission/grant
kimliklerini kaydeder. #46 DACPAC'i bu veritabanına yayımlandığında kimliklerin
ve kullanıcı rol ilişkisinin değişmediğini karşılaştırır. Sonraki tekrar yayın
pasif izin ve iptal edilmiş eşleşmenin geri verilmediğini sınar. Baseline
verildiğinde gerçek SQL destekli Catalog ve API yetki testleri de çalışır.

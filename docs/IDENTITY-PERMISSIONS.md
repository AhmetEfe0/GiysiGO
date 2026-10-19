# Identity rol ve izin temeli — #10

`Scripts/IdentitySeed.sql`, DACPAC PostDeployment sırasında beş sabit rolü,
`PermissionCodes` içindeki dokuz izni ve varsayılan rol–izin eşleşmelerini kurar.
Tekrar yayınlama aynı rol/izin kodunu veya canlı eşleşmeyi çoğaltmaz. Customer
personel izni almaz; StoreStaff `quote.prepare` alır fakat `quote.approve` almaz.
Role/permission kodları sabit anahtardır. PlatformAdmin yalnızca kendisine
tanımlı izinleri alır; hangi HTTP işlemine girebileceği ayrıca doğrulanmalıdır.

`IPermissionChecker.HasPermissionAsync` kimliği, izin kodunu ve istenen
corporate/store kapsamını okur. Bilinmeyen veya pasif/silinmiş kullanıcı, izin,
rol, üyelik ve atama için `false` döndürür. Kapsam verilmezse yalnızca GLOBAL
roller değerlendirilir. Store ID verildiğinde `IStoreScopeReader`, mağazanın
aktifliğini ve corporate kimliğini aynı bağlantı/transaction içinde doğrular;
corporate rolü başka mağazaya taşınmaz. Catalog bu okuyucuyu #14/#21'de
uygulayana kadar store kapsamında güvenli sonuç `false` olur.

`ICurrentUser`, kimliği doğrulanmış isteğin `NameIdentifier` veya `sub`
claim'inden Guid okur. JWT üretimi ve doğrulaması #13'ün işidir. 401/403 Problem
Details, personel atama komutları ve kendine üst rol verme engeli gerçek API
akışlarıyla #10/#15 kapsamında tamamlanmalıdır; bu repository/checker tek başına
bir HTTP güvenlik filtresi değildir.

Gerçek MSSQL testi için `./scripts/Test-IdentityData.ps1` DACPAC'i izole
veritabanına iki kez yayınlar. Bu, seed tekrarını, izin eşleşmelerini ve kapsam
okumalarını doğrular. Mevcut Linux CI bağlantı değişkeni yoksa DB testlerini
skipped gösterir; gerçek DB CI entegrasyonu #19 kapsamındadır.

# Katalog yönetimi ve Identity yetkilendirmesi

Katalog okumaları anonim kullanılabilir. Kategori, ürün tipi, hizmet ve ürün/hizmet çifti oluşturma, güncelleme ve silme işlemleri doğrulanmış JWT ve veritabanında GLOBAL kapsamlı `catalog.manage` izni gerektirir.

## Çalışan yazma uçları

| Kaynak | Oluşturma | Güncelleme | Silme |
| --- | --- | --- | --- |
| Kategori | `POST /catalog/categories` | `PUT /catalog/categories/{id}` | `DELETE /catalog/categories/{id}` |
| Ürün tipi | `POST /catalog/product-types` | `PUT /catalog/product-types/{id}` | `DELETE /catalog/product-types/{id}` |
| Hizmet | `POST /catalog/services` | `PUT /catalog/services/{id}` | `DELETE /catalog/services/{id}` |
| Ürün/hizmet çifti | `POST /catalog/product-type-services` | `PUT /catalog/product-type-services/{id}` | `DELETE /catalog/product-type-services/{id}` |

Oluşturma `201` ve sunucunun ürettiği kimliği, güncelleme/silme `204` döndürür. Silme, `delete_date` ve pasiflik üzerinden uygulanır. Kodlar güncellenemez; çiftin ürün/hizmet kimlikleri başka bir ilişkiye taşınamaz. Aktif ürünü bulunan kategori pasifleştirilemez. Yeni aktif çift için kategori, ürün ve hizmet aktif olmalıdır.

Yanıtta SQL metni veya constraint ayrıntısı verilmez. `400` geçersiz veri, `401` geçersiz/yok token, `403` eksik izin, `404` bulunamayan/uygun olmayan kayıt, `409` yinelenen kayıt veya durum çatışmasıdır. Problem Details gövdesi `code` ve `traceId` içerir.

## JWT yapılandırması

API şu ayarları okur:

| Ayar | Açıklama |
| --- | --- |
| `Jwt:Issuer` / `Jwt__Issuer` | Güvenilen token üreticisi |
| `Jwt:Audience` / `Jwt__Audience` | Token'ın hedef uygulaması |
| `Jwt:SigningKey` / `Jwt__SigningKey` | HS256 için gizli ve güçlü imza anahtarı; UTF-8 olarak en az 32 bayt |

Anahtar ortam değişkeni veya yerel secret deposundan sağlanır; kaynak koda veya repoya gerçek anahtar eklenmez. Ayarlar yokken geçerli kimlik üretilemez ve korunan uçlar açılamaz. Testlerde her uygulama örneği için rastgele test anahtarı üretilir.

İmza, HS256 algoritması, issuer, audience, süre ve tek bir geçerli Guid `sub` denetlenir. Zaman toleransı 30 saniyedir. Kullanıcının hâlâ aktif ve silinmemiş olduğu veritabanından kontrol edilir. `ICurrentUser`, doğrulanan `sub` değerini kullanır; token'daki alternatif kullanıcı kimliği, rol veya permission iddiaları yetki kaynağı değildir. URL ve gövdeden aktör kimliği alınmaz.

Bu teslim JWT doğrulamasını ve gerçek permission tüketimini sağlar. Kayıt/giriş, token üretimi, refresh ve oturum kapatma uçları ayrı #13 akışıdır; bu değişiklik o akışların tamamlandığı iddiasını taşımaz.

## Roller ve kapsamlar

| Rol | Kapsam | Seed izinleri |
| --- | --- | --- |
| Customer | GLOBAL | Personel veya katalog yönetimi izni yok |
| PlatformAdmin | GLOBAL | `PermissionCodes` içindeki 10 izin; `catalog.manage` dahil |
| CorporateOwner | CORPORATE | Katalog yönetimi dışındaki 9 izin; yalnız kendi şirketinde |
| StoreManager | STORE | Katalog yönetimi dışındaki 9 izin; yalnız atandığı dükkânda |
| StoreStaff | STORE | `store.view`, `order.view`, `order.inspect`, `quote.prepare`, `order.process`, `order.fulfill` |

`quote.prepare` ve `quote.approve` ayrıdır. Kapsamsız denetimde yalnız GLOBAL roller değerlendirilir. Şirket denetimi aktif şirket ve aktif üyelik gerektirir. Dükkân denetiminde gerçek şirket, Catalog'un `IStoreScopeReader` sağlayıcısıyla aynı transaction içinde bulunur; gönderilen şirket bununla uyuşmuyorsa erişim reddedilir. Şirket rolü kendi şirketinin dükkânlarında, dükkân rolü yalnız aktif ataması bulunan dükkânda geçerlidir. StoreStaff için şirket sahibi üyeliği aranmaz; aktif dükkân ataması kendi üyeliğidir.

Pasif/silinmiş kullanıcı, rol, permission, üyelik, atama, şirket veya dükkân ilgili erişimi kapatır. İzin iptali JWT süresinin dolmasını beklemeden uygulanır. Veritabanı hataları izin yokmuş gibi `false` değerine çevrilmez.

## Seed ve ilk yönetici

`node docs/generate-identity-permission-seed.mjs`, ortak `PermissionCodes` sabitlerinden ve yukarıdaki rol matrisinden `IdentityPermissionsSeed.sql` üretir. Post-deployment bu seed'i de çalıştırır. Kimlikler sabittir; tekrar çalıştırmada rol/permission çoğalmaz. Mevcut pasiflik veya iptal kayıtları yeniden etkinleştirilmez.

Seed kullanıcı oluşturmaz, parola belirlemez ve kullanıcıya yönetici rolü atamaz. İlk yönetici, önceden oluşturulmuş aktif kullanıcıya güvenilen yönetim kanalıyla `identity.spGrantUserRole` üzerinden PlatformAdmin rolü atanarak hazırlanır. HTTP katalog uçları kullanıcıya rol atayamaz; istemci kendini yöneticiye yükseltemez.

## Doğrulama

`scripts/Test-CatalogData.ps1` gerçek SQL, gerçek JWT doğrulayıcısı ve gerçek HTTP host'u kullanır. Testlerde üretim permission sağlayıcısı veya authentication handler sahte bir sağlayıcıyla değiştirilmez. Müşteri/personel/şirket sahibi için `403`, anonim/geçersiz token için `401`, yönetici için yazma başarısı, kapsam taşması, iptal ve pasiflik senaryoları denetlenir.

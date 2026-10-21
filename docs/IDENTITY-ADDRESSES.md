# Identity müşteri profili ve adresleri — #16

Bu belge `feature/identity-issue-16` dalındaki uygulamayı anlatır. `main` durumu
olarak yorumlanmamalıdır. Temel veri erişimi #6, JWT kimliği #13 üzerinden gelir.

## HTTP davranışı

- `GET /me/profile` yalnız `id` ve `email` döndürür. `PUT /me/profile` yalnız
  `email` günceller; tanımsız gövde alanları `400` alır. Parola hash'i, roller ve `is_active` değişmez. E-posta
  benzersizliği SQL Server'ın case-insensitive canlı kullanıcı indeksindedir.
- `GET /me/addresses?page=1&pageSize=20` yalnız aktif, silinmemiş ve token'daki
  kullanıcıya ait adresleri `{items,page,pageSize,totalCount}` olarak döndürür.
  `pageSize` en fazla 100'dür; sayfalama SQL prosedüründe yapılır.
  `GET /me/addresses/{addressId}` tek adresi okur.
- `POST /me/addresses` adresi ekler ve `201` + `id` verir; `PUT` alanları
  değiştirir, `DELETE` soft-delete yapar ve `204` döndürür. İstek gövdesindeki
  `userId` sahiplik oluşturmaz. URL'deki başka kullanıcıya ait adres `404` alır.
- `label`, `addressText`, `contactName`, `contactPhone` boş olamaz. İlk üç alanın
  üst sınırı sırasıyla 100, 2000 ve 200 karakterdir. Telefon, isteğe bağlı baştaki
  `+` işaretinden sonra 7–15 rakam içerir. Latitude [-90,90], longitude
  [-180,180] ve en fazla altı ondalık basamak olur. Geçersiz istek `400`
  (`validation_error`), tekrarlanan e-posta `409` (`email_conflict`) alır.
  Yanıtlarda parola hash'i ve aktiflik alanı yoktur.

## Veri akışı ve transaction

`CustomerSelfService`, `ITransactionRunner` içinde mevcut Identity repository'leri
ile çalışır. Repository'ler yalnız `database/GiysiGo.Database/identity/Stored
Procedures` altındaki prosedürleri çağırır. E-posta güncellemesi
`spSetOwnEmail` ile aktif kullanıcıya sınırlıdır. Adresin yazılması ve silinmesi
`spInsertCustomerAddress`, `spUpdateOwnedCustomerAddress` ve
`spDeleteOwnedCustomerAddress` ile `user_id`, `is_active`, `delete_date`
denetimlerinden geçer. Tek adres okuması `spGetOwnedCustomerAddress`, liste API'si
`spGetCustomerAddressPage` kullanır; repo içindeki tam liste metodu
`spGetCustomerAddressesByUser` prosedürünü kullanmaya devam eder.

`CustomerAddressReader`, aynı snapshot'ı `ICustomerAddressReader` ve
`ITransactionalCustomerAddressReader` üzerinden sağlar. İlk metot kendi
transaction'ını açar; #26 checkout entegrasyonu için hazır olan ikinci metot verilen açık connection ve
ona bağlı transaction'ı kullanır. `spGetOwnedCustomerAddress` satır kilidini
transaction sonuna kadar tutarak checkout adres kopyası alınırken eşzamanlı
güncelleme/silmeyi önler. Mevcut Ordering checkout'u hâlâ `ICustomerAddressReader`
kullanır; aynı transaction'a geçiş #26 kapsamındadır. Boş GUID `ArgumentException`, başka kullanıcı/pasif/
silinmiş adres `null` döner; DB hatası saklanmaz.

`ordering.order_address_snapshots` checkout anında kopyalanan ayrı kayıttır.
Adres defterindeki update/delete bu tabloya yazmaz. Gerçek SQL testinde adres
kopyası oluşturulup adres güncellendikten ve silindikten sonra kopyanın aynı
kaldığı denetlenir.

Yerel doğrulama: `pwsh -NoProfile -File scripts/Test-IdentityData.ps1`
DACPAC'i iki kez yayımlar, ardından Identity ve API SQL testlerini çalıştırır.
Windows Application Control `Release` API DLL'sini engellerse
`-ApiConfiguration Debug` ile aynı ayrı test veritabanında API testleri Debug
derlemesiyle çalıştırılabilir. Varsayılan derleme `Release` olarak kalır.

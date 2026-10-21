# Identity kayıt ve oturum akışı — #13

`POST /auth/register` yalnızca e-posta ve parola alır. Sunucu e-postayı doğrular,
ASP.NET Core PasswordHasher ile tek yönlü hash üretir ve kullanıcı ile GLOBAL
`Customer` rolünü aynı SQL transaction'ında yazar. Body'deki rol, şirket ve dükkân
bilgisi kullanılmaz. Canlı e-posta benzersizliği SQL Server'da case-insensitive
indeksle korunur; yinelenen e-posta 409 döner. Kayıt 201 ve `userId` üretir,
oturum açmaz. Parola 12–128 karakter olmalıdır.

`POST /auth/login` aynı hata cevabını bilinmeyen kullanıcı, yanlış parola ve
pasif/silinmiş hesap için döner. Başarılı giriş yapılandırılmış ömürlü imzalı
access JWT ve 30 günlük rastgele refresh token döner. JWT `sub` claim'i kullanıcı
Guid'idir; issuer, audience, imza anahtarı ve access token süresi `Jwt`
yapılandırmasından gelir. `Jwt:SigningKey` en az 32 UTF-8 bayt olmalı, repoya
yazılmamalı; ortam değişkeni `Jwt__SigningKey` veya kullanıcı sırlarıyla
sağlanmalıdır. `Jwt__Issuer`, `Jwt__Audience` ve `Jwt__AccessTokenMinutes` da
ortam bazında ayarlanır. Access token süresi 1–60 dakikadır. JWT doğrulaması
issuer, audience, imza ve bitiş zamanını sıfır clock skew ile kontrol eder.
Geçerli imzalı token'ın `sub` kullanıcısı pasif veya silinmişse istek yine 401
alır; host bunu `IUserRepository` ile doğrular.

Refresh token 64 kriptografik rastgele baytın Base64 gösterimidir. Veritabanındaki
`identity.auth_sessions.token_hash` yalnızca SHA-256 hash'ini saklar.
`POST /auth/refresh` verilen token'ı tek transaction içinde tüketip yenisini ekler;
aynı token ikinci kez, süresi dolduktan, iptal edildikten veya kullanıcı pasif
olduktan sonra kullanılamaz. Eşzamanlı iki refresh isteğinde satır kilidi
yalnızca birinin yeni oturum açmasına izin verir. `POST /auth/logout` verilen
refresh token'ı iptal eder; tekrar çağrı no-op'tur. Access JWT kendi kısa süresine
kadar geçerlidir; çıkış onu anında kara listeye almaz. İstemci çıkışta access
token'ı da silmelidir.

Her SQL çağrısı `identity` prosedürü üzerinden `IAuthSessionRepository`,
`IIdentityAccessRepository` veya `IUserRepository` ile yapılır; C# içinde SQL
sorgusu bulunmaz. Kayıt, giriş,
yenileme ve çıkışın çok tablolı değişiklikleri `ITransactionRunner` kullanır.
`AuthSession`, diğer entity'ler gibi Guid `Id` ve create/update/delete tarihleri
taşır. Endpoint'ler hassas hash veya session satırını dışarı vermez. Geçersiz
giriş/refresh 401, doğrulama 400, e-posta çakışması 409 Problem Details döner.

`scripts/Test-IdentityData.ps1` ayrı LocalDB veritabanına DACPAC'i iki kez
yayımlar ve modül/API testlerini çalıştırır. Testler gerçek prosedürlerle
kayıt → giriş → korunan endpoint → refresh → tekrar denemesi → çıkış akışını
doğrular. İlgili DB bağlantısı yokken SQL testleri skipped görünür; bu geçtikleri
anlamına gelmez. Token yapılandırması testte geçici rastgele anahtarla sağlanır.

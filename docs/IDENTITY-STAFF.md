# Şirket ve personel yönetimi — #15

Kimlik JWT'den `ICurrentUser` ile alınır. Şirket ve dükkân personeli komutları
`IStaffAssignmentAuthorizer` kararını, değişiklikle aynı connection/transaction
içinde kullanır. SQL çağrıları Identity repository'lerindedir.

Atama/kaldırma komutu `SERIALIZABLE` izolasyonuyla açılır. Catalog'un kapsam
okuyucusu ve Identity authorizer'ı aynı transaction'a katılır; olumlu kararın
dayandığı kullanıcı, rol, izin, rol–izin, üyelik/atama, şirket ve dükkân kayıtları
commit/rollback'e kadar korunur. Eşzamanlı yetki kaldırma veya pasifleştirme önce
tamamlanırsa komut 403 alır; kontrol önce tamamlanırsa diğer yazma atamanın
bitmesini bekler. Hedef kullanıcı ve rol okumaları `UPDLOCK, HOLDLOCK` kullanır;
grant prosedürlerinin güncelleme kilitleri kontrol sırasında alınır ve mevcut
paralel atama davranışı korunur.
Ortak runner'ın mevcut çağrıları `READ COMMITTED` kullanmayı sürdürür.

| İşlem | Uç | Yetki |
| --- | --- | --- |
| Şirket oluştur | POST /corporates | Aktif GLOBAL PlatformAdmin ve store.staff.manage |
| Şirket aktifliği | PATCH /corporates/{id}/active | Aktif GLOBAL PlatformAdmin ve store.staff.manage |
| Şirket üyelerini listele | GET /corporates/{corporateId}/members | Corporate kapsamlı store.staff.manage |
| Şirket sahibi ata/kaldır | PUT/DELETE /corporates/{corporateId}/members/{userId}/roles/{roleId} | PlatformAdmin, CorporateOwner hedef rolü |
| Dükkân personelini listele | GET /corporates/{corporateId}/stores/{storeId}/staff | Gerçek store kapsamında store.staff.manage |
| Dükkân rolü ata/kaldır | PUT/DELETE /corporates/{corporateId}/stores/{storeId}/staff/{userId}/roles/{roleId} | Aşağıdaki hiyerarşi |
| Kendi erişimini oku | GET /me/access | Doğrulanmış aktif kullanıcı |

Şirket oluşturma gövdesi `{ "name": "Şirket adı" }`, aktiflik gövdesi
`{ "isActive": false }` biçimindedir. Ad 1–200 karakterdir. Eksik aktiflik
ve tanımsız JSON alanları 400 alır. Oluşturma 201 ve `id`, diğer yazmalar
204 döndürür. Şirket ilk oluşturulduğunda aktiftir. Şirket sahibi ayrı üyelik
komutuyla atanır. Şirket oluşturma ve pasifleştirme/yeniden açma PlatformAdmin'e
ayrılmıştır. Şirket sahibinin yetkisi dükkân ve personel yönetimi kapsamındadır.

PlatformAdmin bir şirketin CorporateOwner üyeliğini ve dükkânın
StoreManager/StoreStaff atamasını yönetir. CorporateOwner kendi şirketinin
dükkânlarına StoreManager/StoreStaff atar veya kaldırır. StoreManager yalnız
atandığı dükkânda StoreStaff yönetir. Aktör kendisinin atamasını değiştiremez.
Hedef kullanıcı, rol, şirket ve dükkânın aktifliği mevcut #10 authorizer'ında
denetlenir. Pasif hedefler için komut 403 alır. Customer personel yönetemez.

Store ID ve corporate ID eşleşmesi Catalog'un gerçek `IStoreScopeReader`
sözleşmesinden alınır. Başka modülün tablosuna Identity SQL'iyle sorgu yazılmaz.
Bir personel farklı şirketlerin dükkânlarında farklı rollere sahip olabilir.
Aynı canlı atamanın tekrar verilmesi ikinci kayıt üretmez. Kaldırma soft-delete
yapar, ikinci kaldırma no-op'tur. Yeniden verme önceki geçmiş kaydını koruyup yeni
canlı atama üretir. Bunlar mevcut amaç-özel grant/revoke prosedürleridir.

Personel listeleri `page=1`, `pageSize=20`, üst sınır 100 kullanır.
`{ items, page, pageSize, totalCount }` döner. Toplam ve satırlar aynı geçici
veri kümesinden okunur. Her satır yalnız userId, roleId ve roleCode içerir.
Yöneticiye ait olmayan şirket veya dükkân isteği 403 alır.

`GET /me/access`, GLOBAL/CORPORATE/STORE kayıtları döndürür. Her kayıtta
corporateId, storeId, corporateName, roles ve permissions bulunur. GLOBAL kayıtta
kapsam kimlikleri null'dır. Şirket sahibi kendi aktif üyeliklerini görür.
PlatformAdmin aktif şirketleri görebilir. STORE kayıtları kullanıcının aktif
atamalarından gelir; Catalog'da kapalı/silinmiş dükkân ve Identity'de pasif/silinmiş
şirketler elenir. Dükkân izin özetine aynı şirketin üyeliği ve GLOBAL izinleri de
katılır. Bu özet panel içindir, her komut sunucuda yetkiyi yeniden denetler.

400/401/403/404/409 yanıtları ortak Problem Details biçimindedir. 401 ve 403
authentication Challenge/Forbid akışını kullanır. SQL veya iç hata ayrıntıları
istemciye taşınmaz.

`StaffManagementHttpTests`, gerçek Identity ve Catalog repository/prosedürleriyle
şirket yaşam döngüsü, hiyerarşi, iki şirket/dükkân, kendi rolüne müdahale,
yinelenen ve paralel atama, kaldırma/yeniden verme, sayfalama ve panel özetini
doğrular. HTTP authentication test şemasıdır. JWT doğrulaması mevcut #13 ve
Catalog JWT testlerinde korunur. Testler yalnız ayrılmış veritabanında çalışır.

`StaffAssignmentConcurrencyTests`, gerçek authorizer olumlu karar verdikten sonra
HTTP komutunu atama yazılmadan bekletir. Ayrı SQL bağlantısında yönetici rolünü
veya şirket sahibi üyeliğini kaldırma, şirketi ya da dükkânı pasifleştirme
işlemleri 1500 ms kilit zaman aşımı (1222) alır. Atama 204 ile tamamlandıktan
sonra aynı değişiklik başarılı olur ve sonraki atama 403 alır. Test decorator'ı
yalnız bekleme noktası ekler; yetki kararı ve Catalog kapsamı gerçek SQL'den gelir.

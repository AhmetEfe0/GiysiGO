# Checkout için Catalog okuyucuları (#21)

`IStoreCatalogReader` ve `ITransactionalStoreCatalogReader`, DI üzerinden aynı
`StoreCatalogReader` uygulamasını kullanır. Üç metodun temel uygulaması #14 ile
sağlanmıştır; #21 checkout boyunca kilitlerin korunmasını ve ayrıntılı testlerini tamamlar.

| Metot | Geçerli sonuç | Yok / pasif / silinmiş |
| --- | --- | --- |
| GetOfferingAsync | Store/product/service kimlikleri, decimal UnitPrice, PriceUnit, IsActive=true | null |
| GetStoreLocationAsync | Dükkân kimliği, adres, decimal koordinatlar, IsActive=true | null |
| ServesLocationAsync | Kuş uçuşu km uzaklığı hizmet yarıçapına eşit veya küçükse true | false |

Offering zinciri: aktif şirket → aktif dükkân → aktif offering → aktif
product_type_service → aktif ürün tipi/kategorisi/hizmet. Yanlış ürün veya hizmet
kimliği başka bir kombinasyonun teklifini döndürmez. Silinme her halkada denetlenir.
Fiyat `price_override ?? default_price` olarak decimal kalır; sıfır override geçerlidir.
Fiyat birimi platform kombinasyonunun PIECE/M2 değeridir. Platform şeması default
fiyatın null olmasını engeller ve para birimini TRY ile sınırlar; mevcut snapshot
constructor'ı korunmuştur. Snapshot geçmiş sipariş/teklif satırlarını güncellemez.

## SH1 kararı ve Ordering bağlantısı

SH1'in MODULE-CONTRACTS.md içindeki transaction/kilit yaklaşımını uyguladık;
optimistic version parametresi veya başka modül repository paylaşımı eklemedik.

Önizlemede `IStoreCatalogReader` kullanılabilir. Önizlemede alınan fiyat checkout
fiyatı olarak saklanmamalıdır. Ordering #26 kendi checkout transaction'ında
`ITransactionalStoreCatalogReader` kullanmalıdır:

1. Cart/order kilidi ve müşteriye ait adresi aynı connection/transaction ile alır.
2. Aynı çifti ServesLocationAsync ve gerekirse GetStoreLocationAsync'e verir.
3. Seçilen offering'leri ortak kilit sırasına uygun sırada GetOfferingAsync ile bir
   kez materialize eder. Null veya kapsam dışı sonuçta checkout'u geri alır.
4. Fiyat, birim, miktar, satır ve toplamları bu tek veri setinden üretir; snapshot'ları,
   history ve outbox'ı aynı transaction'a yazar; sonra commit eder.

Catalog, şirket aktifliğini Identity'nin `ICorporateStatusReader` public contract'ı
ile aynı transaction'da doğrular. Catalog SQL'i Identity tablosunu doğrudan okumaz.
Store scope/konum/yarıçap ile offering ve bağlı kategori/ürün/hizmet/fiyat okumaları
`HOLDLOCK` kullanır. READ COMMITTED çağıranda da bu okumalara ait kilitler dış
transaction'ın commit/rollback sonuna kadar tutulur. Bu nedenle okunan fiyatı veya
aktiflik/konum/yarıçapı değiştiren eşzamanlı işlem checkout'un bitmesini bekler;
checkout öncesinde tamamlanan değişiklik yeni okumaya yansır. Uzun transaction'lar
Catalog yönetim yazmalarını bekletebilir; dış servis çağrıları transaction dışında tutulmalıdır.

Transaction alan metotlar bağlantı/transaction açmaz, commit/rollback/dispose etmez.
Açık bağlantı ve ona ait etkin transaction şarttır. Boş Guid/geçersiz koordinat
ArgumentException; iptal OperationCanceledException verir. DB hataları yutulmaz.

Mevcut Ordering checkout'u hâlen transaction almayan okuyucuyu kullanıyor ve
Catalog tablolarını kendi SQL'inde okuyor. Bu geçiş #26'nın sorumluluğundadır;
#21 bu kodu değiştirmez ve tüm checkout entegrasyonunun tamamlandığını iddia etmez.
Sağlayıcı bu belge ve public contract'larla tüketilmeye hazırdır. #17, PR #57 ile
main'e birleştirildi; #21 dalı bu güncel main üzerine taşınmıştır.

## Doğrulama

Catalog testleri gerçek SQL'de iki fiyat birimini, default/override/sıfır/üst sınır
fiyatlarını; yanlış ürün/hizmet/dükkânı; her halkada pasiflik ve soft delete'i;
yarıçap içi/dışı adresi; aynı transaction'da rollback, iptal ve bağlantı eşleşmesini
kapsar. İkinci bağlantıda fiyat/override/aktiflik zinciri/konum/yarıçap değişiklikleri
kilit timeout'u ile doğrulanır; dış transaction bitince aynı değişiklik başarılı olur.

Testte Identity Infrastructure referansı yerine Identity'nin gerçek SQL contract'ını
çağıran test adaptörü kullanılır. API entegrasyon testleri gerçek Identity DI
uygulamasını da kapsar. Standart `scripts/Test-StoreManagementData.ps1` ayrılmış
SQL Server 2022 üzerinde DACPAC'i iki kez uygular ve testleri çalıştırır.

Yerel doğrulama — 11 Kasım 2026: Catalog 24, API 85, sözleşmeler 20 olmak üzere
129 test başarılı; başarısız/atlanan yok. DACPAC iki kez uygulandı. Catalog test
projesinin Release derlemesi -warnaserror ile 0 hata ve 0 uyarı verdi. Bu sonuçlar
#17 ile aynı kaynak ağacını içeren güncel main üzerine taşınan #21 çalışma
ağacına aittir; GitHub CI sonucu değildir.

## Kabul ölçütü ve kanıt eşleştirmesi

| Görev maddesi | Uygulama / doğrulama | Durum |
| --- | --- | --- |
| Üç metot ve transaction overload'ları | StoreCatalogReader; gerçek DI ile CheckoutCatalogContractTests | Catalog sağlayıcısı tamam |
| Corporate/store ve offering → kombinasyon → ürün/kategori/hizmet zinciri | IsActiveAsync + usp_GetValidStoreOffering; Inactive_and_deleted_links_return_null_or_false_consistently | Her halkada aktiflik ve soft delete doğrulandı |
| Override/default fiyatı ve birim snapshot'ı | COALESCE; Offering_resolves_decimal_prices_units_and_rejects_wrong_combinations | PIECE/M2, decimal, null override, sıfır ve üst sınır doğrulandı |
| Yanlış/yok/kapalı kombinasyon null; kapsam dışı false | Offering_resolves_decimal_prices_units_and_rejects_wrong_combinations ve Inactive_and_deleted_links_return_null_or_false_consistently | Sağlayıcı davranışı doğrulandı |
| SH1 transaction kararı | Dört Catalog okuma prosedüründe HOLDLOCK; Identity şirket okuyucusu aynı transaction'da | Optimistic version eklenmedi; commit/rollback'e kadar koruma doğrulandı |
| Değişen fiyat/aktiflik/konum/yarıçap | Checkout_reads_hold_price_and_every_active_link_until_caller_finishes; Location_and_coverage_each_protect_their_own_store_reads | İkinci bağlantıdaki değişiklik bloke olur, transaction bitince başarılıdır |
| Hata/iptal/rollback sınırları | Reader_preserves_caller_rollback_and_propagates_validation_and_cancellation; Database_lock_errors_are_not_hidden_as_missing_offerings_or_coverage | Okuyucu caller transaction'ını sahiplenmez; SQL hatası null/false olmaz |
| Ordering'in kendi Catalog SQL'i olmadan okuma yapabilmesi | CheckoutCatalogContractTests public interface'leri gerçek Identity/Catalog DI ile kullanır; fixture SQL'i yalnız test verisi hazırlar | Contract üzerinden teklif/konum/kapsama ve aynı transaction kanıtlandı |
| Üretim Ordering checkout'una bağlama | [#26](https://github.com/DOU-SEProjects/GiysiGO/issues/26), MODULE-CONTRACTS.md son teslim planı | Henüz tamamlanmadı; OrderingWorkflowService eski okuyucuyu kullanıyor, SQL'deki Catalog okumaları da kaldırılmalı |
| .NET / DACPAC / istemci | Yerel SQL test raporları, Release derlemesi, GitHub CI | Yeni HTTP veya istemci özelliği yok; istemci kontrolü bu değişiklikte uygulanabilir değil |

Bu tablo sağlayıcı testini tüm checkout'un uçtan uca testi olarak sunmaz. #21'in
Catalog implementasyonu ve contract davranışı teslim edilir; gerçek Ordering
checkout entegrasyonu #26 ile tamamlanmadan tüm checkout akışına onay verilemez.

## Birleştirme ve #26 bağımlılığının yönü

#26, #21'e bağımlıdır; #21'in Catalog sağlayıcısının birleştirilmesi #26'nın
bitmesini gerektirmez. Sağlayıcı kodu inceleme ve ilgili kontroller sonrasında
main'e alınabilir; bu, Ordering ekibinin gerçek implementasyonu kullanmasını sağlar.
#21'deki public contract'tan teklif/konum alınabilmesi gerçek DI testinde doğrulanır.
Üretim Ordering checkout'unun aynı transaction'daki bu okuyucuya geçirilmesi
#26'nın teslimidir. Bu entegrasyon açıkken uygulamanın tüm checkout akışının
fiyat/aktiflik yarışlarına karşı korunduğu veya uçtan uca tamamlandığı söylenemez.
Bu durum #21 sağlayıcısının merge engeli değildir; checkout'un üretim teslimi için
#26 entegrasyonu ve uçtan uca doğrulama gerekir.


## Tüm backend için ek yerel kontrol — 11 Kasım 2026

Son çalışma ağacı altı test projesiyle ayrılmış SQL Server 2022 üzerinde tekrar
kontrol edildi: Catalog 24, API 85, Identity 21, Ordering 9, Operations 1,
sözleşmeler 20; toplam 160 başarılı, 0 başarısız, 0 atlanan test.
DACPAC iki kez uygulandı. API ve bağlı dört modülün Release derlemesi
-warnaserror ile 0 hata, 0 uyarı verdi. Bu bir yerel regresyon sonucudur;
üretim checkout'unun #26 entegrasyonunun tamamlandığı anlamına gelmez.

# Dükkân yönetimi #14 doğrulama takibi

Branch: `codex/catalog-store-management`. Başlangıç: #10 / PR #46 commit `7dc8764`.
#11 değişiklikleri bu branch'e alınmadı. Kullanıcı 9 Kasım 2026'da mevcut çalışmanın commit/push edilerek, #10 sonrası tekrar doğrulama notuyla taslak PR açılmasını onayladı. Ayrı GitHub yorumu veya merge için onay verilmedi.

## Kapatmadan önce zorunlu tekrar kontrolü

- [x] Kullanıcının isteği: son inceleme öncesinde tekrar eden kodları ortaklaştır, dosya ve sorguları incelemesi kolay olacak şekilde sadeleştir; davranışın korunduğunu testleri yeniden çalıştırarak doğrula. Altı okuma prosedürünün ortak görünürlük filtresi `catalog.v_VisibleStores` görünümüne taşındı; son kaynaklarla tam test turu yeniden geçti.

- [ ] #10 sahibinin seed atomikliği düzeltmesini güncel commit üzerinden incele.
- [ ] Gerçek SQL Server üzerinde seed'in rol/izin yazımı ortasında kontrollü hata oluştur; önceki durumun aynen korunduğunu, kısmi rol/izin/eşleşme kalmadığını ve açık transaction bırakılmadığını doğrula.
- [ ] Düzeltilmiş #10 seed'iyle başarılı tekrarın kayıt çoğaltmadığını, pasif izinleri ve iptal edilmiş eşleşmeleri yeniden açmadığını yeniden doğrula.
- [ ] Düzeltilmiş #10 ile #14'ün gerçek Identity/Catalog entegrasyon testlerini yeniden çalıştır.

8 Kasım 2026 incelemesinde eski seed için hata sonrasında 5 rol kaldığı doğrulandı. Bu bulgu düzeltilip yeniden test edilene kadar yukarıdaki maddeler açık kalır. Geliştirme testlerinin başarılı olması bu açık kontrolün yerine geçmez.

## #14 mevcut kaynaklarının doğrulaması — 8 Kasım 2026

`scripts/Test-StoreManagementData.ps1` son kaynaklarla başarılı bitti. SQL Server 2022 LocalDB `16.0.1000.6`, SQL 2022 DACPAC hedefi ve `AllowIncompatiblePlatform=false` kullanıldı. Release DACPAC derlendi, ayrılmış veritabanına iki kez yayımlandı; testlerden sonra veritabanı ve `GGST_39e8e1fa1c69` örneği temizlendi.

| Paket | Geçen | Başarısız | Atlanan |
| --- | ---: | ---: | ---: |
| Catalog | 2 | 0 | 0 |
| API | 21 | 0 | 0 |
| Identity | 15 | 0 | 0 |
| Ordering | 9 | 0 | 0 |
| Operations | 1 | 0 | 0 |
| Ortak sözleşmeler | 19 | 0 | 0 |
| **Toplam** | **67** | **0** | **0** |

Yerel günlük `database/GiysiGo.Database/bin/Release/store-management-verification.log`; altı TRX dosyası aynı derleme klasörünün `StoreVerification/` altındadır. Bunlar ignored yerel çıktılardır; uzak CI sonucu değildir. İlk DB bağlantısı olmadan yapılan derleme turunda SQL testleri açıkça atlandı; yukarıdaki son tur bağlantı sağlanmış ve sıfır atlamalı turdur.

### Kabul ölçütleri ve test kanıtları

| Ölçüt | Kanıt |
| --- | --- |
| Bir şirket birden fazla fiziksel dükkân yönetir | `Owner_manages_multiple_stores_with_shared_pagination_and_no_corporate_leak`: iki şube, varsayılan 1/20, ikinci sayfa, toplam ve çok ileri boş sayfa |
| Şirket aidiyeti değiştirilemez; başka şirkete yazılamaz | `Other_corporate_ids_cannot_move_or_modify_a_store`: yanlış şirketle 403/404, gövdede corporateId için 400, gerçek scope ile değişmeyen aidiyet |
| Yetkili güncelleme ve aktiflik | `Updates_and_repeated_activation_preserve_corporate_and_allow_reopening`: PUT, tekrar pasifleştirme, pasif ayrıntı/liste filtresi, yeniden açma |
| Müşteri/personel/yönetici sınırları | `Anonymous_requests_are_challenged_and_customer_cannot_manage`, `Store_staff_and_manager_can_read_only_assigned_active_store_and_cannot_manage`: 401/WWW-Authenticate, 403, izinli PlatformAdmin, yalnız atanmış dükkânda personel okuması |
| İzin iptali hemen uygulanır | `Revoked_corporate_membership_closes_write_access_without_changing_http_identity`: HTTP kimliği korunurken gerçek üyelik iptali sonrası 403 |
| Koordinat, ölçü, eksik/bilinmeyen alan ve sayfalama | `Invalid_fields_missing_measurements_unknown_fields_and_bad_pagination_are_rejected`; `Direct_sql_validation_and_missing_store_updates_do_not_create_extra_rows`: API 400 ve doğrudan SQL 52300, yüksek hassasiyetli geçersiz değerlerin sessiz yuvarlanmaması |
| Pasif/silinmiş şirket ve dükkân müşteri akışından çıkar | `Inactive_or_deleted_corporate_and_store_are_hidden_from_location_and_permission_reads`: gerçek location/coverage/checker ve HTTP okumaları |
| Identity personel ataması gerçek Catalog contract'ını kullanır | `Identity_staff_authorizer_uses_real_store_reader_and_rejects_other_corporate`: gerçek DI, authorizer/repository/SP/okuyucu; izinli şirket, yanlış şirket ve kendine atama |
| Konum/kilometre ve transaction sözleşmesi | `Location_reader_uses_supplied_transaction_and_checks_kilometre_coverage`: merkez, içerisi/dışarısı; başka bağlantının transaction'ı reddedilir; aynı transaction'da pasifleştirme görünür ve rollback sonrası aktif kayıt korunur |
| Arayüzün tamamı çalışır | `Complete_reader_contract_filters_all_relations_and_resolves_override_prices`: varsayılan/override fiyat, beş pasif ilişki, transaction alan offering okuması |
| #14 izin seed'i tekrar ve iptalleri korur | `Store_seed_preserves_ids_and_does_not_restore_disabled_or_revoked_permissions`: iki grant, aynı kimlikler, pasif izin ve iptal edilmiş eşleşme; transaction rollback ile test değişiklikleri geri alınır |
| HTTP sözleşmesi koda uyar | `StoreContractTests`: beş gerçek MVC yolu, yazma policy'leri, sayfalama varsayılanları, DTO alanları, zorunlu ölçü/aktiflik alanları, yasak actor/şirket alanları; 404/405 ortak Problem Details |
| Bölgesel ayar bağımsızlığı | Türkçe `tr-TR` ve İngilizce `en-US` için ondalık sınır doğrulaması |

İlk uygulama turunda geçerli isteklerin 400 alması, `RangeAttribute` ondalık sınırlarının Türkçe kültürde okunamamasından kaynaklandı. Invariant parse/convert ayarları ve iki kültür testiyle giderildi; düzeltilmiş kaynaklarla tam tur tekrarlandı. İlk script sürüm kontrolündeki çıktı biçimi eşleşmesi de düzeltildi. Başarısız denemeler son başarı gibi sunulmadı.

## İnceleme sırası ve sınırlar

1. `STORE-MANAGEMENT.md`: uçlar, yetki, birimler ve mesai saatleri ihtiyacı.
2. `StoreManagementService` ve `StoresController`: komutlar, DTO ve scope kontrolleri.
3. `usp_ManageStore` / `v_VisibleStores`: transaction, şirket aidiyeti, ortak aktiflik filtresi.
4. `StoreScopeReader` / `StoreCatalogReader`: gerçek Identity entegrasyonu ve public okuyucular.
5. HTTP/SQL testleri ve `mvp-contracts.json`: kanıtlar ve ortak sözleşme.

Identity Domain/Infrastructure'a Catalog tarafından referans eklenmedi; #10'un checker/authorizer veya IdentitySeed kaynakları değiştirilmedi. `store.manage` ortak permission sabiti ve #14'e özel seed eklendi. #11'in seed/karar/yönetim değişiklikleri bu branch'e taşınmadı.

Gerçek JWT bağlaması #13 kapsamındadır; HTTP testlerinde authentication test şeması, izin/kapsam kararlarında gerçek Identity kullanılır. İstemci projesi bu branch'te bulunmadığından istemci testi yoktur. DB CI altyapısı #19 sınırındadır. #10 seed düzeltmesi ve birleşim sonrası tekrar kontrolü açıkken #10/#14 birlikte kapanmaya hazır ilan edilmez.

Taslak PR, yalnız #14 farkının incelenmesi için başlangıçta `feature/identity-issue-10` branch'ini hedefler. #10 kontrolü ve birleşiminden sonra hedef `main` olarak güncellenmeli, kaynaklar uzlaştırılmalı ve bu doğrulama turu yeniden çalıştırılmalıdır. Bu maddeler tamamlanana kadar merge'e hazır kabul edilmez. Ayrı GitHub yorumu ve merge yapılmaz.

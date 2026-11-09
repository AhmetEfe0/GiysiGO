# Dükkân yönetimi #14 doğrulama takibi

Branch: `codex/catalog-store-management`. Başlangıç: #10 / PR #46 commit `7dc8764`.
Güncel #10 `a02fa0f` ve onun içerdiği #11 değişiklikleriyle uyumlandırıldı. Güncel JWT doğrulaması, ortak API hata yanıtları ve iki teslimin Catalog kayıtları korundu. PR, #10 birleşene kadar `feature/identity-issue-10` branch'ini hedefler.

## Güncel branch doğrulaması — 10 Kasım 2026

İnceleme kopyasında doğrulanan dokuz çakışma çözümü asıl branch'e aktarıldı. `StoreJwtTests` kalıcı test paketine eklendi. `scripts/Test-StoreManagementData.ps1` asıl kaynaklarla yeniden çalıştırıldı: SQL Server 2022 LocalDB `16.0.1000.6`, SQL160 DACPAC hedefi, `AllowIncompatiblePlatform=false`; Release derleme ve iki kez yayın başarılı.

| Paket | Geçen | Başarısız | Atlanan |
| --- | ---: | ---: | ---: |
| Catalog | 9 | 0 | 0 |
| API | 51 | 0 | 0 |
| Identity | 15 | 0 | 0 |
| Ordering | 9 | 0 | 0 |
| Operations | 1 | 0 | 0 |
| Ortak sözleşmeler | 20 | 0 | 0 |
| **Toplam** | **105** | **0** | **0** |

Yerel günlük: `database/GiysiGo.Database/bin/Release/store-management-current-verification.log`. Altı TRX: aynı klasördeki `StoreVerification/`. Test veritabanı ve `GGST_563a70bfef70` örneği çalışma sonunda temizlendi. Bunlar yerel sonuçlardır; GitHub CI sonucu olarak sunulmaz. Aşağıdaki 67 testlik bölüm eski teslimin tarihsel kaydıdır.

## Kapatmadan önce zorunlu tekrar kontrolü

- [x] Kullanıcının isteği: son inceleme öncesinde tekrar eden kodları ortaklaştır, dosya ve sorguları incelemesi kolay olacak şekilde sadeleştir; davranışın korunduğunu testleri yeniden çalıştırarak doğrula. Altı okuma prosedürünün ortak görünürlük filtresi `catalog.v_VisibleStores` görünümüne taşındı; son kaynaklarla tam test turu yeniden geçti.

- [x] #10 sahibinin seed atomikliği düzeltmesini `a02fa0f` üzerinden incele.
- [x] SQL Server 2022 üzerinde seed'in rol/izin yazımı ortasında kontrollü hata oluştur; dış transaction varken/yokken dört yetki tablosunda kısmi kayıt ve açık transaction kalmadığını doğrula. Başarılı seed'in dış transaction'ı erken kapatmadığı ve dış rollback ile değişikliklerin geri alındığı da doğrulandı.
- [x] Düzeltilmiş #10 seed'iyle başarılı tekrarın kayıt çoğaltmadığını, pasif izinleri ve iptal edilmiş eşleşmeleri yeniden açmadığını doğrula.
- [x] Düzeltilmiş #10 ile #14'ün gerçek Identity/Catalog entegrasyon testlerini inceleme kopyasında çalıştır: 105 geçti, başarısız/atlanan yok.
- [ ] #10 sahibinin ortak test hazırlığı düzeltmesinden sonra iki teslimin son commit'lerini birlikte doğrula ve inceleme onaylarını tamamla. Bu son kontrol ekip arkadaşı tarafından yapılabilir.

8 Kasım 2026 incelemesinde eski seed için hata sonrasında 5 rol kaldığı doğrulandı. Güncel #10, transaction kullanan `IdentityPermissionsSeed.sql` dosyasına geçti; kontrollü hata senaryoları yeniden çalıştırılarak bu bulgu kapatıldı.

Kalan test hazırlığı bulgusu: `IdentityPermissionTests.cs` içindeki seed testi, `order.fulfill` izninin önceden pasifleştirilmesini bekler. `Test-IdentityData.ps1` ve #14'ün `Test-StoreManagementData.ps1` script'i `PrepareSeedRedeploy.sql` ile bu hazırlığı yapar; `Test-CatalogData.ps1` yapmadığı için güncel #10'da bir Identity testi başarısız olur. Testin kendi hazırlığını yapması #10 sahibinden istendi. Bu, uygulamada yetki ihlali olduğu anlamına gelmez; ortak test çalıştırmasının dış hazırlık bağımlılığıdır.

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

Identity Domain/Infrastructure'a Catalog tarafından referans eklenmedi. `store.manage` ortak permission sabiti ve #14'e özel seed, güncel #10 ve #11 altyapısıyla birlikte çalışır. #10'un checker/authorizer iş kurallarına #14 tarafından yeni davranış eklenmedi.

Güncel JWT doğrulaması korunur; `StoreJwtTests` gerçek JWT, Identity ve SQL ile sahip/personel erişimini ve aktiflik sınırlarını birlikte doğrular. Diğer yönetim HTTP testlerinde authentication test şeması, izin/kapsam kararlarında gerçek Identity kullanılır. Giriş/refresh/token üretimi #13 kapsamındadır. İstemci projesi bu branch'te bulunmadığından istemci testi yoktur. DB CI altyapısı #19 sınırındadır.

PR, yalnız #14 farkının incelenmesi için başlangıçta `feature/identity-issue-10` branch'ini hedefler. #10 test hazırlığı düzeltmesi ve son ortak doğrulama ile inceleme onayları tamamlandıktan sonra önce #10 birleştirilir. Ardından #14 hedefi `main` olarak güncellenip son fark ve kontroller değerlendirilir. İncelemeye hazır olması, merge onayının tamamlandığı anlamına gelmez.

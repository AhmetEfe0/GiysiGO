# Dükkân yönetimi #14 doğrulama takibi

Branch: `codex/catalog-store-management`. Başlangıç: #10 / PR #46 commit `7dc8764`.
Güncel `main` commit `a0639da` ile uyumlandırıldı; #10 / PR #46 ve #13 / PR #47 birleşmiştir. PR hedefi `main`dir. Güncel JWT doğrulaması ve Catalog/Identity testleri korunur.

## 11 Kasım 2026 — güncel main ile belge çakışması çözümü

`main` commit `a0639da` (#13 / PR #47) branch'e alındı. Tek metin çakışması `MODULE-CONTRACTS.md` içindeki OpenAPI açıklamasındaydı: #14'ün beş dükkân işlemi ve #13'ün dört oturum ucu birlikte korunarak çözüldü. Otomatik birleşen OpenAPI ve Identity servis kayıtlarında iki çalışmanın kayıtları da kontrol edildi.

Birleşik kaynaklarla SQL Server 2022 LocalDB'de Release DACPAC derlemesi, iki kez yayın ve seed `--check` başarılı. **121 geçti, 0 başarısız, 0 atlanan** — Catalog 9, API 65, Identity 17, Ordering 9, Operations 1, Contracts 20. #13'ün main'den gelen iki testi toplamı 119'dan 121'e çıkardı. Kanıt: `database/GiysiGo.Database/bin/Release/store-14-main-a0639da-verification.log`, `StoreVerification/*.trx`. `GGST_c981ef2bff14` örneği temizlendi. Sonuçlar yereldir; bu uyumlandırma PR'ın main'e merge edildiği anlamına gelmez.

## 11 Kasım 2026 — ikinci reviewer dönüşü: repository ve namespace

[Reviewer yorumu](https://github.com/DOU-SEProjects/GiysiGO/pull/53#issuecomment-6791508571) önceki üç bulgunun düzeldiğini ve yeni bir işlevsel hata doğrulanmadığını belirtiyor. Ancak iki proje düzeni ihlali önceki kaynak incelemesinde atlanmıştı; başarılı çalışma testleri bu kuralları denetlemiyordu.

- `spIsCorporateActive` çağrısı ve bağlantı/transaction doğrulaması `ICorporateRepository.IsActiveAsync` / `CorporateRepository` içine taşındı. `CorporateStatusReader` repository'ye aynı kimlik, bağlantı, transaction ve cancellation token ile delegasyon yapar. Yeni bağlantı veya transaction açmaz; commit/rollback yapmaz.
- `ExactDecimalConverter` blok namespace biçimine çevrildi; dönüşüm mantığı aynı kaldı. İlgili dosyalarda file-scoped namespace ve reader içindeki doğrudan Dapper çağrısı kaynak üzerinden ayrıca kontrol edildi.

Son tekrar: **119 geçti, 0 başarısız, 0 atlanan** — Catalog 9, API 64, Identity 16, Ordering 9, Operations 1, Contracts 20. API paketindeki mevcut şirket aktifliği/rollback, yanlış bağlantı, cancellation ve eşzamanlı değişiklik testleri repository üzerinden de geçti. SQL Server 2022 üzerinde Release DACPAC derlemesi, iki kez yayın ve seed `--check` başarılı. Kanıt: `database/GiysiGo.Database/bin/Release/store-14-repository-style-2026-11-11.log`, `StoreVerification/*.trx`. `GGST_88729c87f49c` örneği temizlendi. Bu iki düzen düzeltmesi yereldedir; henüz commit/push/yorum yapılmadı.

## 11 Kasım 2026 — yalnız #14 için önceki inceleme

Dükkân oluşturma/güncelleme/aktiflik işlemleri, yetki ve şirket sınırları, konum doğrulaması, sayfalama, ortak şirket aktiflik sözleşmesi ve izin seed'i yeniden incelendi. Yeni doğrulanmış hata bulunmadı; uygulama kodunda ek değişiklik yapılmadı.

`StoreManagementHttpTests`, `StoreJwtTests`, `CorporateStatusContractTests`, `StoreSeedUpgradeTests` ve `StoreNumberBoundaryTests` içindeki **27 test geçti**. Aynı doğrulama script'inin bağlantılı paketleriyle toplam **119 geçti, 0 başarısız, 0 atlanan**. SQL Server 2022 üzerinde Release DACPAC derlemesi ve iki kez yayın başarılı. Kanıt: `database/GiysiGo.Database/bin/Release/store-14-last-check-2026-11-11.log`, `StoreVerification/*.trx`. `GGST_21276cff9b62` örneği temizlendi. Sonuçlar yereldir; GitHub'a gönderim yapılmadı.

## Önceki ayrıntılı kontrol — 119 test

10 Kasım 2026: API girdileri/DTO, gerçek JWT ve Identity izinleri, şirketler arası erişim, aktif/pasif ve soft-delete davranışı, sayfalama, SQL transaction/rollback, ortak modül sözleşmeleri ve eski seed'den yükseltme yeniden incelendi.

Ek bulgu: JSON okuyucusu çok uzun ondalıkları doğrulamadan önce yuvarlayabiliyordu. `90.00000000000000000000000000001` enlemi 90'a, `1e-100` sıfıra dönüşüyordu. İki regresyon testi önce başarısız oldu (`store-number-audit-before.log`). Ölçü alanlarına değer kaybını reddeden `ExactDecimalConverter` eklendi. Tam bilimsel gösterim, negatif değerler, sıfır ve sondaki sıfırlar korunuyor; mevcut basamak/aralık kontrolleri ayrıca uygulanıyor. Gerçek HTTP testi, üç ölçü alanında hatalı isteğin 400 dönmesini ve kayıt oluşturmamasını, geçerli bilimsel gösterimin 201 dönmesini doğruladı.

Son tam script çalışması: **119 geçti, 0 başarısız, 0 atlanan** — Catalog 9, API 64, Identity 16, Ordering 9, Operations 1, Contracts 20. SQL Server 2022 LocalDB `16.0.1000.6`, SQL160 hedefi, Release DACPAC derlemesi ve iki kez yayın başarılı. Ortak seed üreticisinin `--check` kontrolü geçti. Kanıt: `database/GiysiGo.Database/bin/Release/store-final-deep-audit.log` ve `StoreVerification/*.trx`. `GGST_fb7f8d9ef74b` örneği temizlendi.

Bu kanıtlar yerel sunucu/veritabanı testleridir. İstemci projesi bu kopyada yoktur; istemci ve tüm proje için uçtan uca doğrulama iddiası değildir. Uzak CI'daki SQL bağlantı değişkenleri yerel script ile aynı değildir; 119 testin CI'da da çalıştığı iddia edilmez. GitHub'a yayın, PR hedefini `main` yapma ve yeniden inceleme henüz beklemektedir.

## Önceki doğrulama — eski seed'den güvenli yükseltme

`scripts/Test-StoreManagementData.ps1` son kaynaklarla SQL Server 2022 LocalDB `16.0.1000.6` üzerinde tamamlandı; SQL160 DACPAC Release derlemesi ve iki kez yayın başarılı. Ortak üreticinin `--check` kontrolü geçti.

| Paket | Geçen | Başarısız | Atlanan |
| --- | ---: | ---: | ---: |
| Catalog | 9 | 0 | 0 |
| API | 56 | 0 | 0 |
| Identity | 16 | 0 | 0 |
| Ordering | 9 | 0 | 0 |
| Operations | 1 | 0 | 0 |
| Ortak sözleşmeler | 20 | 0 | 0 |
| **Toplam** | **111** | **0** | **0** |

Kanıt: `database/GiysiGo.Database/bin/Release/store-seed-upgrade-final.log` ve `StoreVerification/*.trx`. `GGST_9c94915edf6f` test örneği temizlendi.

`StoreSeedUpgradeTests` aktif, pasif, silinmiş izin ve iptal edilmiş grant durumlarında eski rastgele GUID'den sabit GUID'e geçişi ve tekrarı doğrular. İzin metadata'sı, grant kimlikleri/tarihleri ve iptaller aynen korunur. Tanınmayan kayıt, başka izin tarafından kullanılan hedef GUID ve geçişten sonraki seed adımında hata senaryoları 52100 ile durur; dış transaction geri alındığında ilk veriler aynen kalır.

Ayrıca eski #14 DACPAC'iyle kurulmuş ayrı veritabanında gerçek DACPAC yükseltmesi yapıldı. Önceden pasifleştirilmiş izin ve iptal edilmiş CorporateOwner grant'iyle yeni sürüme geçiş ve tekrar yayın başarılı; kimlik dışındaki izin alanları ile grant kimlikleri/tarihleri korunmuştur. Kanıt: `database/GiysiGo.Database/bin/Release/store-upgrade-audit-fixed.log`. `GGA14_7ee89be67ffd` veritabanı/örneği temizlendi. Bunlar yerel doğrulamalardır.

### Önceki yükseltme bulgusu — giderildi

Kullanıcının tekrar inceleme isteği üzerine eski #14 DACPAC'iyle ayrı SQL Server 2022 veritabanı kuruldu. Bu sürüm `store.manage` kimliğini rastgele üretir. Yeni ortak `IdentityPermissionsSeed.sql` bu veritabanına uygulandığında sabit kimlik uyuşmazlığı nedeniyle 52100 hatasıyla durdu. Yeni kurulumdaki 109 test bu eski kurulumdan yükseltme senaryosunu kapsamıyordu.

Ortak seed'e yalnız eski #14 kaydını tanıyan atomik geçiş eklendi ve yukarıdaki testlerle doğrulandı. Üretim veya kullanıcının mevcut veritabanları değiştirilmedi. İlk başarısız denemenin kanıtı: ignored yerel `database/GiysiGo.Database/bin/Release/store-upgrade-audit.log`. O denemedeki `GGA14_1fd8d58fcbed` örneği de kapatılıp kaldırıldı.

## Önceki 109 testlik doğrulama — yükseltme kontrolünden önce

`scripts/Test-StoreManagementData.ps1` son kaynaklarla başarılı bitti. SQL Server 2022 LocalDB `16.0.1000.6`, SQL160 DACPAC hedefi ve `AllowIncompatiblePlatform=false` kullanıldı; Release derleme ve iki kez yayın geçti. Eski Identity hazırlığı çalıştırılmadı. Test veritabanı ve `GGST_f8a6e7483f92` örneği temizlendi.

| Paket | Geçen | Başarısız | Atlanan |
| --- | ---: | ---: | ---: |
| Catalog | 9 | 0 | 0 |
| API | 54 | 0 | 0 |
| Identity | 16 | 0 | 0 |
| Ordering | 9 | 0 | 0 |
| Operations | 1 | 0 | 0 |
| Ortak sözleşmeler | 20 | 0 | 0 |
| **Toplam** | **109** | **0** | **0** |

Yerel günlük `database/GiysiGo.Database/bin/Release/store-reviewer-fixes-final.log`; altı TRX aynı klasördeki `StoreVerification/` altındadır. Bunlar uzak CI sonuçları değildir. İlk turdaki GUID metninin harf büyüklüğü karşılaştırması GUID değeri karşılaştırmasına çevrildi; yukarıdaki sonuç düzeltilmiş testle yapılan tam tekrar turudur.

| Reviewer bulgusu | Düzeltme ve kanıt |
| --- | --- |
| Çift seed / farklı GUID | Ayrı #14 seed'i kaldırıldı. Ortak üretici `store.manage` için sabit `8b314bca-963a-5231-b7d0-768947eebe68` kimliğini, yalnız PlatformAdmin/CorporateOwner eşleşmelerini üretir. Üretici tekrarında dosya hash'i değişmedi; `--check` geçti. `Store_seed_preserves_ids_and_does_not_restore_disabled_or_revoked_permissions` DACPAC sonrasında ortak seed'i iki kez çalıştırır; sabit kimlik, iki rol, pasif izin ve iptal korunur. |
| Eski Identity hazırlığı | Script'ten `PrepareSeedRedeploy.sql` çağrısı kaldırıldı; temiz ortak seed ile 16 Identity testi geçti. |
| Şirket aktifliği / modül sınırı | Catalog görünümü ve komutu Identity tablosunu okumaz. `ICorporateStatusReader` Identity sağlayıcısına aynı bağlantı/transaction ile gider. `Scope_keeps_corporate_identity_while_identity_contract_hides_inactive_parent` pasif/silinmiş şirkette scope'un gerçek şirketi koruduğunu, Identity yetki ve Catalog müşteri okumalarının erişimi kapattığını, rollback sonrası durumun geri geldiğini doğrular. |
| Karar ve yazma arasındaki aktiflik değişikliği | `Active_corporate_decision_is_held_until_the_callers_transaction_ends`: ikinci bağlantının şirketi pasifleştirmesi çağıranın transaction'ı bitene kadar engellenir; transaction sonrasında pasifleştirme gerçekleşir. |
| Yönetim repository sınırı | `Management_repository_uses_identity_status_before_reading_or_writing`: pasif şirketin liste/ayrıntısı sunulmaz, oluşturma ve aktiflik yazması reddedilir. Yeniden aktifleştirince kayıt korunur. |

## Önceki branch doğrulaması — dd77e41, 10 Kasım 2026

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
- [x] #10 sahibinin ortak test hazırlığı düzeltmesini güncel main üzerinden al; #14 script'indeki eski hazırlık çağrısını kaldır.
- [x] Reviewer'ın üç düzeltmesini ve eski seed'den geçişi güncel kaynaklarla doğrula: 111 geçti, başarısız/atlanan yok; eski DACPAC'ten yükseltme/tekrar yayın başarılı.
- [ ] PR hedefi ve açıklamasını güncelle; reviewer'ın yeniden inceleme onayını tamamla.

8 Kasım 2026 incelemesinde eski seed için hata sonrasında 5 rol kaldığı doğrulandı. Güncel #10, transaction kullanan `IdentityPermissionsSeed.sql` dosyasına geçti; kontrollü hata senaryoları yeniden çalıştırılarak bu bulgu kapatıldı.

Önceki test hazırlığı bulgusu #10'da çözülmüştür: `IdentitySeedTests` hazırlığı kendi transaction'ında yapıp geri alır. #14 script'indeki eski `PrepareSeedRedeploy.sql` çağrısı kaldırıldı. Identity paketi temiz seed verisiyle çalışır.

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
| Ortak izin seed'i tekrar ve iptalleri korur | `Store_seed_preserves_ids_and_does_not_restore_disabled_or_revoked_permissions`: sabit GUID, iki yetkili rol, aynı kimlikler, pasif izin ve iptal edilmiş eşleşme; transaction rollback ile test değişiklikleri geri alınır |
| HTTP sözleşmesi koda uyar | `StoreContractTests`: beş gerçek MVC yolu, yazma policy'leri, sayfalama varsayılanları, DTO alanları, zorunlu ölçü/aktiflik alanları, yasak actor/şirket alanları; 404/405 ortak Problem Details |
| Bölgesel ayar bağımsızlığı | Türkçe `tr-TR` ve İngilizce `en-US` için ondalık sınır doğrulaması |

İlk uygulama turunda geçerli isteklerin 400 alması, `RangeAttribute` ondalık sınırlarının Türkçe kültürde okunamamasından kaynaklandı. Invariant parse/convert ayarları ve iki kültür testiyle giderildi; düzeltilmiş kaynaklarla tam tur tekrarlandı. İlk script sürüm kontrolündeki çıktı biçimi eşleşmesi de düzeltildi. Başarısız denemeler son başarı gibi sunulmadı.

## İnceleme sırası ve sınırlar

1. `STORE-MANAGEMENT.md`: uçlar, yetki, birimler ve mesai saatleri ihtiyacı.
2. `StoreManagementService` ve `StoresController`: komutlar, DTO ve scope kontrolleri.
3. `usp_ManageStore` / `v_VisibleStores`: transaction, şirket aidiyeti, ortak aktiflik filtresi.
4. `StoreScopeReader` / `StoreCatalogReader`: gerçek Identity entegrasyonu ve public okuyucular.
5. HTTP/SQL testleri ve `mvp-contracts.json`: kanıtlar ve ortak sözleşme.

Identity Domain/Infrastructure'a Catalog tarafından referans eklenmedi. `store.manage` ortak permission sabiti ve ortak Identity seed'i kullanılır; ayrı #14 seed'i kaldırılmıştır. `ICorporateStatusReader` Identity tarafından sağlanır; Catalog yalnız BuildingBlocks sözleşmesini kullanır. #10'un checker/authorizer iş kurallarına yeni davranış eklenmedi.

Güncel JWT doğrulaması korunur; `StoreJwtTests` gerçek JWT, Identity ve SQL ile sahip/personel erişimini ve aktiflik sınırlarını birlikte doğrular. Diğer yönetim HTTP testlerinde authentication test şeması, izin/kapsam kararlarında gerçek Identity kullanılır. Giriş/refresh/token üretimi #13 kapsamındadır. İstemci projesi bu branch'te bulunmadığından istemci testi yoktur. DB CI altyapısı #19 sınırındadır.

#10 birleşmiştir; PR hedefi `main` olarak güncellenip reviewer düzeltmeleri son kaynaklar üzerinden yeniden incelenmelidir. İncelemeye hazır olması, merge onayının tamamlandığı anlamına gelmez.

# Stored procedure sözleşmesi

Stellar.Automation örneğinde `RepositoryBase<T>` beş temel prosedür adı ister: listeleme, ID ile okuma, ekleme, güncelleme ve silme. Modelin ihtiyacına göre istasyon/ilişki filtreli ek okuma prosedürleri bulunur. GiysiGO'daki `RepositoryBase<TEntity>` de aynı beş işlemi bekler. Bu nedenle **bu sınıftan türeyen her repository** beş prosedürü kendi modülünün SQL şemasında sağlamalıdır. Her tablo için repository veya beş CRUD prosedürü zorunlu değildir.

| İşlem | Örnek ad | Dapper beklentisi |
| --- | --- | --- |
| Liste | `[catalog].[spGetAllProductCategories]` | Satırlar `ProductCategory` alanlarına eşlenir |
| Tek kayıt | `[catalog].[spGetProductCategoryById]` | `@Id uniqueidentifier`; kayıt yoksa boş sonuç |
| Ekle | `[catalog].[spInsertProductCategory]` | `InsertParameters(entity)`; **tek satır/tek sütun GUID sonuç** |
| Güncelle | `[catalog].[spUpdateProductCategory]` | `UpdateParameters(entity)`; `@Id` içerir |
| Sil | `[catalog].[spDeleteProductCategory]` | `@Id uniqueidentifier`; `delete_date` ayarlanır |

İsimlerde SQL şeması ve çoğul tablo adı tutarlı olmalı. Her prosedür `SET NOCOUNT ON` kullanır. Okuma sorguları `delete_date IS NULL` uygular; varsa `is_active` ayrıca iş amacına göre filtrelenir. Dapper eşlemesi için snake_case sütunlar `AS Id`, `AS CreateDate`, `AS UpdateDate`, `AS DeleteDate` gibi C# alan adlarına çevrilir. Tarihler `SYSUTCDATETIME()` ile yazılır.

Automation'ın `spInsert` prosedürleri `@InsertedId OUTPUT` kullanır. GiysiGO `RepositoryBase.InsertAsync` ise `QuerySingleAsync<Guid>` çağırır; burada prosedür **`SELECT @NewId AS Id`** döndürmelidir. Output parametresini aynen kopyalamak bu repository ile çalışmaz. Bir ekleme prosedürü `@Id uniqueidentifier = NULL` kabul edebilir; null veya `00000000-0000-0000-0000-000000000000` ID geldiğinde yeni GUID oluşturup döndürür. `InsertParameters` ile gönderilen alan adları ve SQL parametreleri bire bir eşleşmelidir.

Basit yönetim kayıtları (örneğin katalog kategorileri, ürün tipleri, hizmetler, dükkân fiyat tanımları veya müşteri adresleri) uygun yetki ve kapsam kontrolünden sonra repository CRUD kullanabilir. E-posta/parola güncellemesi, rol ataması ve şirket/dükkân üyeliği özel yetki kontrolleriyle yapılır. Sipariş, teklif, ödeme, teslim görevi, atama ve geçmiş tablolarında serbest `Update/Delete` açılmaz; bu kayıtlar durum geçişi, idempotency ve transaction kuralları olan amaç-özel prosedür/komutlarla değişir. Bu sınıflar için genel `RepositoryBase` kullanmak gerekmez.

`GetAll` prosedürü bütün kullanıcıları/siparişleri istemciye açmak anlamına gelmez. Müşteri, dükkân, durum, hizmet ve tarih filtreleri için ayrı isimli okuma prosedürleri yazılır; büyük listeler sayfalanır. Checkout, kesin teklif, ödeme ve kurye ataması tek transaction içinde çoklu Dapper komutları kullanır. `RepositoryBase` her çağrıda ayrı bağlantı açtığından bu işlemlerde kullanılmaz.

SQL dosyası ilgili modülün `database/GiysiGo.Database/<schema>/Stored Procedures/` klasörüne eklenir. SQL projesi yeni dosyayı otomatik dahil eder. Modül sahibi prosedürleri kendi entity/repository implementasyonuyla birlikte ve DACPAC derlemesiyle doğrular.

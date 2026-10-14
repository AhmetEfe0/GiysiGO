# Ortak Dapper sözleşmesi

GiysiGO, Stellar.Automation'daki `EntityBase<TId>` + `RepositoryBase` fikrini MSSQL ve dört modül için uyarlıyor. Station senkronizasyonu için yazılmış `SyncableRepositoryBase` bu projeye taşınmıyor.

- Her iş entity'si `EntityBase<Guid>` kalıtımı alır. Genel tür parametresi başka kimlik tiplerine izin verir; mevcut 39 tablonun anahtarı GUID'dir. C# `CreateDate` / `UpdateDate` / `DeleteDate` alanları SQL'deki `create_date` / `update_date` / `delete_date` sütunlarına eşlenir.
- `IRepository<TEntity>` ve `RepositoryBase<TEntity>` ortak CRUD imzalarını sağlar; kimlik tipi veritabanındaki gibi `Guid`'dir. `InsertAsync(TEntity entity)` bir `Guid` döndürür. Her modül kendi entity repository'sini, `[schema].[spGet...]` gibi prosedürlerini ve parametre eşlemesini yazar. `spInsert` tek satırda yeni ID'yi döndürür; `spDelete` `delete_date = SYSUTCDATETIME()` yapar. Okuma prosedürleri `delete_date IS NULL` uygular. Dapper sütun adları için sorguda `AS Id`, `AS CreateDate` gibi alias kullanılır.
- Bağlantı tek `SqlConnectionFactory` üzerinden açılır; connection string API host konfigürasyonundan gelir. Şifre kaynak koda girmez.
- Repository tabanı tek sorguluk CRUD içindir. Çok tablolı checkout, teklif yayını, ödeme ve kurye ataması kendi application servisinde **tek SQL transaction** kullanır; repository tabanının her çağrıda yeni bağlantı açan metotları bu işlemler içinde kullanılmaz. Aynı connection/transaction'ı alan Dapper komutları veya ayrı transaction-aware modül repository metotları yazılır.
- Modül sınırı SQL şemasıyla belirlenir: Identity, Catalog, Ordering ve Operations. Bir modül başka modülün entity/repository sınıfına bağlanmaz; public application contract ve outbox olayı kullanır. Şemadaki FK'ler veri bütünlüğü içindir.
- SQL prosedürü ve tablo dosyaları `database/GiysiGo.Database` içinde ilgili şema klasöründedir. Prosedürlerin ilk sürümü modül implementasyonuyla birlikte gelir.

Başlangıç kodu `src/BuildingBlocks` altında ve `GiysiGo.sln` içindedir. Dört kişi aynı anda modül klasörlerinde çalışabilir; API host, ortak sözleşme ve aynı SQL dosyasındaki değişiklikler ortak inceleme ister.

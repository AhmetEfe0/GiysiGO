# GiysiGO PostgreSQL şeması

`schema.sql` boş bir PostgreSQL veritabanına uygulanacak referans DDL'dir. `.NET 10` uygulamasında her geliştirici kendi modülünün EF Core migration'larını bu yapıya göre üretir. Aynı veritabanında hem bu DDL hem migration'lar çalıştırılmaz.

```powershell
psql -v ON_ERROR_STOP=1 -d giysigo -f database/schema.sql
```

Dosya 4 iş şemasında 38 tablo ve `building_blocks.outbox_messages` altyapı tablosu oluşturur. Uygulama GUID değerlerini üretir; SQL seed veya mock kurye verisi içermez. Katalog girdileri `docs/catalog-draft.json` dosyasındadır. Fiyat birimi belirsiz üç perde hizmeti, doğrudan terzi girişindeki 16 işlem ve olası çift ücretli kombinasyonlar iş kuralları netleşince seed edilir.

Ana ilişkiler:

```mermaid
erDiagram
    corporates ||--o{ stores : owns
    users ||--o{ customer_addresses : has
    product_categories ||--o{ product_types : contains
    product_types ||--o{ product_type_services : supports
    services ||--o{ product_type_services : applies_to
    stores ||--o{ store_offerings : enables
    product_type_services ||--o{ store_offerings : priced_by
    users ||--o{ orders : places
    stores ||--o{ orders : fulfills
    orders ||--|{ order_items : contains
    order_items ||--|{ order_item_services : requests
    orders ||--o{ price_quotes : receives
    price_quotes ||--|{ price_quote_lines : details
    orders ||--o{ delivery_tasks : needs
    delivery_tasks ||--o{ delivery_assignments : assigned_as
    courier_profiles ||--o{ delivery_assignments : receives
    order_items ||--o| item_inspections : inspected_by
    order_item_services ||--o| item_work : performed_as
```

Şemada modüller arası foreign key bulunur fakat .NET modülleri diğer modülün entity sınıfını veya DbContext'ini referanslamaz. Başka modüllerin verilerini public contract ve integration event ile alır. `identity.store_assignments` tablosu `catalog.stores` kaydına bağlı olduğu için migration sırası plan dosyasında açıklanmıştır.

SQL'in sağlayamadığı kurallar application transaction'larında uygulanır: adresin müşteriye ait olması; sepet hizmetinin hem ürün tipine hem seçili dükkâna uygun olması; teklif ve ödeme tutarlarının satır toplamıyla eşleşmesi; izin verilen durum geçişleri; çakışan görevlerde kurye kapasitesi; rolün permission'ı ve şirket/dükkân kapsamı. Bu kontroller için entegrasyon testleri gereklidir.

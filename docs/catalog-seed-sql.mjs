// Üretici verileri doğrular; bu modül tablo biçimindeki veriyi ve ortak SQL işlemlerini yazar.
const quote = value => `N'${String(value).replaceAll("'", "''")}'`;
const comment = value => String(value).replaceAll(/[\r\n]+/g, ' ');

function insertRows(table, columns, rows) {
  const batches = [];
  for (let offset = 0; offset < rows.length; offset += 1000) {
    const batch = rows.slice(offset, offset + 1000);
    batches.push(`INSERT ${table} (${columns}) VALUES\n${batch.map((row, index) =>
      `    (${row.values.join(', ')})${index === batch.length - 1 ? ';' : ','}${row.note ? ` -- ${comment(row.note)}` : ''}`
    ).join('\n')}`);
  }
  return batches.join('\n');
}

export function buildCatalogSeed({ draft, decisions, pairs, excluded, guidFor }) {
  const categories = insertRows('@SeedCategories', 'id, code, name, sort_order', draft.categories.map((row, index) => ({
    values: [quote(guidFor(`category:${row.code}`)), quote(row.code), quote(row.name), index]
  })));
  const products = insertRows('@SeedProducts', 'id, code, category_code, name, base_unit', draft.products.map(row => ({
    values: [quote(guidFor(`product:${row.id}`)), quote(row.id), quote(row.categoryCode), quote(row.name), quote(row.baseUnit)]
  })));
  const services = insertRows('@SeedServices', 'id, code, name', draft.services.map(row => ({
    values: [quote(guidFor(`service:${row.id}`)), quote(row.id), quote(row.name)]
  })));
  const combinations = insertRows('@SeedPairs', 'id, product_code, service_code, default_price, price_unit, selection_kind', pairs.map(row => ({
    values: [quote(guidFor(`product-service:${row.productId}:${row.serviceId}`)), quote(row.productId), quote(row.serviceId), row.defaultPriceTry.toFixed(2), quote(row.priceUnit), quote(row.selectionKind)],
    note: `Seed çifti ${row.productId}/${row.serviceId} (${row.priceUnit}, ${row.selectionKind}${row.tailoringNote})`
  })));
  const exclusions = insertRows('@ExcludedPairs', 'product_code, service_code', excluded.map(row => ({
    values: [quote(row.productId), quote(row.serviceId)],
    note: `Kapsam dışında ${row.productId}/${row.serviceId}: ${row.reason}`
  })));
  const tailoring = decisions.excludedTailoringEntries.map(row =>
    `-- Kapsam dışı terzi kalemi ${row.tailoringEntryIndex + 1}: ${comment(row.reason)}`).join('\n');

  return `-- docs/generate-catalog-seed.mjs tarafından üretilmiştir. Bu dosyayı doğrudan düzenlemeyin.
-- Kimlikler sabit kaynak kodlarından türetilir; kapsam dışı veya karar bekleyen çiftler aktif sunulmaz.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- Kaynak veriler: her kayıt tek satırdır; ilişkiler okunabilir kaynak kodlarıyla belirtilir.
DECLARE @SeedCategories TABLE (id uniqueidentifier NOT NULL, code nvarchar(100) PRIMARY KEY, name nvarchar(200) NOT NULL, sort_order int NOT NULL);
DECLARE @SeedProducts TABLE (id uniqueidentifier NOT NULL, code nvarchar(100) PRIMARY KEY, category_code nvarchar(100) NOT NULL, name nvarchar(200) NOT NULL, base_unit nvarchar(20) NOT NULL);
DECLARE @SeedServices TABLE (id uniqueidentifier NOT NULL, code nvarchar(100) PRIMARY KEY, name nvarchar(200) NOT NULL);
DECLARE @SeedPairs TABLE (id uniqueidentifier NOT NULL, product_code nvarchar(100) NOT NULL, service_code nvarchar(100) NOT NULL, default_price decimal(12,2) NOT NULL, price_unit nvarchar(20) NOT NULL, selection_kind nvarchar(30) NOT NULL, PRIMARY KEY (product_code, service_code));
DECLARE @ExcludedPairs TABLE (product_code nvarchar(100) NOT NULL, service_code nvarchar(100) NOT NULL, PRIMARY KEY (product_code, service_code));

${categories}

${products}

${services}

${combinations}

${tailoring}
${exclusions}

BEGIN TRY
    BEGIN TRANSACTION;

    -- Kod/GUID uyuşmazlığı varsa hiçbir kalıcı değişiklik yapılmadan durulur.
    IF EXISTS (SELECT 1 FROM [catalog].product_categories t WITH (UPDLOCK, HOLDLOCK) JOIN @SeedCategories s ON s.code = t.code WHERE t.id <> s.id)
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: kategori.', 1;
    IF EXISTS (SELECT 1 FROM [catalog].product_types t WITH (UPDLOCK, HOLDLOCK) JOIN @SeedProducts s ON s.code = t.code WHERE t.id <> s.id)
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ürün.', 1;
    IF EXISTS (SELECT 1 FROM [catalog].services t WITH (UPDLOCK, HOLDLOCK) JOIN @SeedServices s ON s.code = t.code WHERE t.id <> s.id)
        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: hizmet.', 1;
    IF EXISTS (
        SELECT 1 FROM [catalog].product_type_services t WITH (UPDLOCK, HOLDLOCK)
        JOIN @SeedProducts p ON p.id = t.product_type_id
        JOIN @SeedServices v ON v.id = t.service_id
        JOIN @SeedPairs s ON s.product_code = p.code AND s.service_code = v.code
        WHERE t.id <> s.id
    ) THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ürün/hizmet çifti.', 1;

    -- Kategoriler, ürünler ve hizmetler: mevcut kimlikleri koru, yalnız eksikleri ekle.
    UPDATE t SET name = s.name, sort_order = s.sort_order,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].product_categories t JOIN @SeedCategories s ON s.code = t.code;
    INSERT [catalog].product_categories (id, code, name, sort_order, is_active)
    SELECT s.id, s.code, s.name, s.sort_order, 1 FROM @SeedCategories s
    WHERE NOT EXISTS (SELECT 1 FROM [catalog].product_categories t WITH (UPDLOCK, HOLDLOCK) WHERE t.code = s.code);

    UPDATE t SET category_id = c.id, name = s.name, base_unit = s.base_unit,
        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].product_types t JOIN @SeedProducts s ON s.code = t.code
    JOIN @SeedCategories c ON c.code = s.category_code;
    INSERT [catalog].product_types (id, category_id, code, name, base_unit, is_active)
    SELECT s.id, c.id, s.code, s.name, s.base_unit, 1 FROM @SeedProducts s
    JOIN @SeedCategories c ON c.code = s.category_code
    WHERE NOT EXISTS (SELECT 1 FROM [catalog].product_types t WITH (UPDLOCK, HOLDLOCK) WHERE t.code = s.code);

    UPDATE t SET name = s.name, is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].services t JOIN @SeedServices s ON s.code = t.code;
    INSERT [catalog].services (id, code, name, is_active)
    SELECT s.id, s.code, s.name, 1 FROM @SeedServices s
    WHERE NOT EXISTS (SELECT 1 FROM [catalog].services t WITH (UPDLOCK, HOLDLOCK) WHERE t.code = s.code);

    -- Çiftler: fiyat/birim kararlarını uygula; başlangıçta hiçbir hizmet seçili değildir.
    UPDATE t SET default_price = s.default_price, currency = 'TRY', price_unit = s.price_unit,
        selection_kind = s.selection_kind, is_default_selected = 0, is_active = 1,
        delete_date = NULL, update_date = SYSUTCDATETIME()
    FROM [catalog].product_type_services t
    JOIN @SeedProducts p ON p.id = t.product_type_id
    JOIN @SeedServices v ON v.id = t.service_id
    JOIN @SeedPairs s ON s.product_code = p.code AND s.service_code = v.code;
    INSERT [catalog].product_type_services
        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)
    SELECT s.id, p.id, v.id, s.default_price, 'TRY', s.price_unit, s.selection_kind, 0, 1
    FROM @SeedPairs s JOIN @SeedProducts p ON p.code = s.product_code
    JOIN @SeedServices v ON v.code = s.service_code
    WHERE NOT EXISTS (
        SELECT 1 FROM [catalog].product_type_services t WITH (UPDLOCK, HOLDLOCK)
        WHERE t.product_type_id = p.id AND t.service_id = v.id
    );

    -- Kapsam dışı çiftleri ekleme; önceki dağıtımdan kaldılarsa pasifleştir.
    UPDATE t SET is_active = 0, is_default_selected = 0, update_date = SYSUTCDATETIME()
    FROM [catalog].product_type_services t
    JOIN [catalog].product_types p ON p.id = t.product_type_id
    JOIN [catalog].services v ON v.id = t.service_id
    JOIN @ExcludedPairs s ON s.product_code = p.code AND s.service_code = v.code;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
`;
}

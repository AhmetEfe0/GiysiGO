import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const draft = JSON.parse(readFileSync(resolve(root, 'docs/catalog-draft.json'), 'utf8'));
const decisions = JSON.parse(readFileSync(resolve(root, 'docs/catalog-decisions.json'), 'utf8'));
const outputPath = resolve(root, 'database/GiysiGo.Database/Scripts/CatalogSeed.sql');
const namespace = Buffer.from('8cfc71ce7b3b4c759b54489e41080a1f', 'hex');

if (decisions.initialServiceSelection !== 'none'
    || decisions.serviceSelectionRequired !== true
    || decisions.minimumPrimarySelection !== true) {
  throw new Error('Seed üretilmeden önce hizmet seçimi kararları onaylanmalıdır.');
}

const quote = value => `N'${String(value).replaceAll("'", "''")}'`;
const guidFor = value => {
  const digest = createHash('sha1').update(Buffer.concat([namespace, Buffer.from(value, 'utf8')])).digest();
  digest[6] = (digest[6] & 0x0f) | 0x50;
  digest[8] = (digest[8] & 0x3f) | 0x80;
  const hex = digest.subarray(0, 16).toString('hex');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
};

const assertUnique = (values, label) => {
  if (new Set(values).size !== values.length) throw new Error(`${label} benzersiz olmalıdır.`);
};

assertUnique(draft.categories.map(row => row.code), 'Kategori kodları');
assertUnique(draft.products.map(row => row.id), 'Ürün kodları');
assertUnique(draft.services.map(row => row.id), 'Hizmet kodları');
assertUnique(draft.productServices.map(row => `${row.productId}/${row.serviceId}`), 'Ürün/hizmet çiftleri');

const categoryCodes = new Set(draft.categories.map(row => row.code));
const productsById = new Map(draft.products.map(row => [row.id, row]));
const servicesById = new Map(draft.services.map(row => [row.id, row]));
const pendingPairs = new Set([
  ...decisions.pendingProductServices,
  ...decisions.excludedProductServices
].map(row => `${row.productId}/${row.serviceId}`));
const unitOverrides = new Map(decisions.productServiceUnitOverrides.map(row => [
  `${row.productId}/${row.serviceId}`,
  row.priceUnit
]));
const kindOverrides = new Map(decisions.productServiceKindOverrides.map(row => [
  `${row.productId}/${row.serviceId}`,
  row.selectionKind
]));
const mappedTailoringIndexes = new Set();
const mappedTailoringPairs = new Set();
const tailoringMappingsByPair = new Map();
for (const mapping of decisions.tailoringEntryMappings) {
  const pair = `${mapping.productId}/${mapping.serviceId}`;
  if (!Number.isInteger(mapping.tailoringEntryIndex)
      || mapping.tailoringEntryIndex < 0
      || mapping.tailoringEntryIndex >= draft.tailoringEntry.length
      || mappedTailoringPairs.has(pair)
      || !draft.productServices.some(row => `${row.productId}/${row.serviceId}` === pair)) {
    throw new Error(`${mapping.tailoringEntryIndex} numaralı terzi kaleminin ${pair} eşleşmesi geçersiz veya yinelenmiş.`);
  }
  mappedTailoringIndexes.add(mapping.tailoringEntryIndex);
  mappedTailoringPairs.add(pair);
  const mappings = tailoringMappingsByPair.get(pair) ?? [];
  mappings.push(mapping.tailoringEntryIndex);
  tailoringMappingsByPair.set(pair, mappings);
}
const excludedTailoringIndexes = new Set();
for (const exclusion of decisions.excludedTailoringEntries) {
  if (!Number.isInteger(exclusion.tailoringEntryIndex)
      || exclusion.tailoringEntryIndex < 0
      || exclusion.tailoringEntryIndex >= draft.tailoringEntry.length
      || excludedTailoringIndexes.has(exclusion.tailoringEntryIndex)
      || mappedTailoringIndexes.has(exclusion.tailoringEntryIndex)
      || !exclusion.reason) {
    throw new Error(`${exclusion.tailoringEntryIndex} numaralı terzi kaleminin kapsam dışı kararı geçersiz veya çelişkili.`);
  }
  excludedTailoringIndexes.add(exclusion.tailoringEntryIndex);
}
for (let index = 0; index < draft.tailoringEntry.length; index += 1) {
  if (!mappedTailoringIndexes.has(index) && !excludedTailoringIndexes.has(index)) {
    throw new Error(`${index + 1} numaralı terzi kaleminin onaylanmış eşleşmesi veya kapsam dışı kararı yok.`);
  }
}
for (const [pair, selectionKind] of kindOverrides) {
  if (!['BASE', 'ALTERNATIVE', 'ADD_ON'].includes(selectionKind)
      || !draft.productServices.some(row => `${row.productId}/${row.serviceId}` === pair)) {
    throw new Error(`${pair} için seçim türü kararı geçersiz.`);
  }
}

for (const product of draft.products) {
  if (!categoryCodes.has(product.categoryCode)) throw new Error(`${product.id} üzerindeki ${product.categoryCode} kategorisi bilinmiyor.`);
  const primary = draft.productServices.filter(row => row.productId === product.id && row.kind === 'BASE');
  if (primary.length !== 1) throw new Error(`${product.id} tam olarak bir BASE hizmetine sahip olmalıdır.`);
}

const emitEntity = ({ table, code, id, values, columns }) => {
  const columnList = ['id', ...columns.map(([column]) => column)].join(', ');
  const valueList = [`CONVERT(uniqueidentifier, '${id}')`, ...columns.map(([, value]) => value)].join(', ');
  return `IF EXISTS (SELECT 1 FROM ${table} WHERE code = ${quote(code)})\nBEGIN\n    IF EXISTS (SELECT 1 FROM ${table} WHERE code = ${quote(code)} AND id <> CONVERT(uniqueidentifier, '${id}'))\n        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ${code}.', 1;\n    UPDATE ${table}\n    SET ${values.map(([column, value]) => `${column} = ${value}`).join(',\n        ')},\n        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()\n    WHERE code = ${quote(code)};\nEND\nELSE\nBEGIN\n    INSERT ${table} (${columnList})\n    VALUES (${valueList});\nEND;\n`;
};

const statements = [
  '-- docs/generate-catalog-seed.mjs tarafından üretilmiştir. Bu dosyayı doğrudan düzenlemeyin.',
  '-- Kimlikler sabit kaynak kodlarından türetilir; kapsam dışı veya karar bekleyen çiftler aktif sunulmaz.',
  'SET NOCOUNT ON;',
  'SET XACT_ABORT ON;',
  'BEGIN TRY',
  '    BEGIN TRANSACTION;',
  ''
];

for (const exclusion of decisions.excludedTailoringEntries) {
  statements.push(`-- Kapsam dışı terzi kalemi ${exclusion.tailoringEntryIndex + 1}: ${exclusion.reason.replaceAll(/[\r\n]+/g, ' ')}`);
}
if (decisions.excludedTailoringEntries.length > 0) statements.push('');

draft.categories.forEach((row, index) => {
  const id = guidFor(`category:${row.code}`);
  statements.push(emitEntity({
    table: '[catalog].[product_categories]',
    code: row.code,
    id,
    columns: [['code', quote(row.code)], ['name', quote(row.name)], ['sort_order', String(index)], ['is_active', '1']],
    values: [['name', quote(row.name)], ['sort_order', String(index)]]
  }));
});

draft.products.forEach(row => {
  const id = guidFor(`product:${row.id}`);
  const categoryId = guidFor(`category:${row.categoryCode}`);
  statements.push(`IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = ${quote(row.id)})\nBEGIN\n    IF EXISTS (SELECT 1 FROM [catalog].[product_types] WHERE code = ${quote(row.id)} AND id <> CONVERT(uniqueidentifier, '${id}'))\n        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ${row.id}.', 1;\n    UPDATE [catalog].[product_types]\n    SET category_id = CONVERT(uniqueidentifier, '${categoryId}'), name = ${quote(row.name)}, base_unit = ${quote(row.baseUnit)},\n        is_active = 1, delete_date = NULL, update_date = SYSUTCDATETIME()\n    WHERE code = ${quote(row.id)};\nEND\nELSE\nBEGIN\n    INSERT [catalog].[product_types] (id, category_id, code, name, base_unit, is_active)\n    VALUES (CONVERT(uniqueidentifier, '${id}'), CONVERT(uniqueidentifier, '${categoryId}'), ${quote(row.id)}, ${quote(row.name)}, ${quote(row.baseUnit)}, 1);\nEND;\n`);
});

draft.services.forEach(row => {
  const id = guidFor(`service:${row.id}`);
  statements.push(emitEntity({
    table: '[catalog].[services]',
    code: row.id,
    id,
    columns: [['code', quote(row.id)], ['name', quote(row.name)], ['is_active', '1']],
    values: [['name', quote(row.name)]]
  }));
});

let seededCombinations = 0;
for (const row of draft.productServices) {
  const pair = `${row.productId}/${row.serviceId}`;
  if (pendingPairs.has(pair)) {
    const decision = [...decisions.pendingProductServices, ...decisions.excludedProductServices]
      .find(item => `${item.productId}/${item.serviceId}` === pair);
    statements.push(`-- Kapsam dışında ${pair}: ${decision.reason}\n`);
    statements.push(`UPDATE pts\nSET is_active = 0, is_default_selected = 0, update_date = SYSUTCDATETIME()\nFROM [catalog].[product_type_services] pts\nJOIN [catalog].[product_types] pt ON pt.id = pts.product_type_id\nJOIN [catalog].[services] s ON s.id = pts.service_id\nWHERE pt.code = ${quote(row.productId)} AND s.code = ${quote(row.serviceId)};\n`);
    continue;
  }
  if (!productsById.has(row.productId) || !servicesById.has(row.serviceId)) {
    throw new Error(`Bilinmeyen ürün/hizmet referansı: ${pair}.`);
  }
  const priceUnit = unitOverrides.get(pair) ?? row.priceUnit;
  const selectionKind = kindOverrides.get(pair) ?? row.kind;
  if (!['PIECE', 'M2'].includes(priceUnit)) throw new Error(`${pair} için onaylanmış fiyat birimi yok.`);
  const id = guidFor(`product-service:${row.productId}:${row.serviceId}`);
  const productId = guidFor(`product:${row.productId}`);
  const serviceId = guidFor(`service:${row.serviceId}`);
  const tailoringNote = tailoringMappingsByPair.has(pair)
    ? `; terzi kalemi ${tailoringMappingsByPair.get(pair).map(index => index + 1).join(', ')}`
    : '';
  statements.push(`-- Seed çifti ${pair} (${priceUnit}, ${selectionKind}${tailoringNote})\n`);
  statements.push(`IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '${productId}') AND service_id = CONVERT(uniqueidentifier, '${serviceId}'))\nBEGIN\n    IF EXISTS (SELECT 1 FROM [catalog].[product_type_services] WHERE product_type_id = CONVERT(uniqueidentifier, '${productId}') AND service_id = CONVERT(uniqueidentifier, '${serviceId}') AND id <> CONVERT(uniqueidentifier, '${id}'))\n        THROW 51020, N'Sabit katalog kimliği uyuşmazlığı: ${pair}.', 1;\n    UPDATE [catalog].[product_type_services]\n    SET default_price = ${row.defaultPriceTry.toFixed(2)}, currency = 'TRY', price_unit = ${quote(priceUnit)},\n        selection_kind = ${quote(selectionKind)}, is_default_selected = 0, is_active = 1,\n        delete_date = NULL, update_date = SYSUTCDATETIME()\n    WHERE product_type_id = CONVERT(uniqueidentifier, '${productId}') AND service_id = CONVERT(uniqueidentifier, '${serviceId}');\nEND\nELSE\nBEGIN\n    INSERT [catalog].[product_type_services]\n        (id, product_type_id, service_id, default_price, currency, price_unit, selection_kind, is_default_selected, is_active)\n    VALUES\n        (CONVERT(uniqueidentifier, '${id}'), CONVERT(uniqueidentifier, '${productId}'), CONVERT(uniqueidentifier, '${serviceId}'), ${row.defaultPriceTry.toFixed(2)}, 'TRY', ${quote(priceUnit)}, ${quote(selectionKind)}, 0, 1);\nEND;\n`);
  seededCombinations += 1;
}

statements.push(
  '    COMMIT TRANSACTION;',
  'END TRY',
  'BEGIN CATCH',
  '    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;',
  '    THROW;',
  'END CATCH;',
  ''
);

writeFileSync(outputPath, `${statements.join('\n').trimEnd()}\n`, 'utf8');
console.log(`${outputPath} üretildi: ${draft.categories.length} kategori, ${draft.products.length} ürün, ${draft.services.length} hizmet, ${seededCombinations} aktif ürün/hizmet çifti.`);

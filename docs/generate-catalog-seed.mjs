import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { buildCatalogSeed } from './catalog-seed-sql.mjs';

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

const pairs = [];
const excluded = [];
for (const row of draft.productServices) {
  const pair = `${row.productId}/${row.serviceId}`;
  if (!productsById.has(row.productId) || !servicesById.has(row.serviceId)) {
    throw new Error(`Bilinmeyen ürün/hizmet referansı: ${pair}.`);
  }
  if (pendingPairs.has(pair)) {
    const decision = [...decisions.pendingProductServices, ...decisions.excludedProductServices]
      .find(item => `${item.productId}/${item.serviceId}` === pair);
    excluded.push({ ...row, reason: decision.reason });
    continue;
  }
  const priceUnit = unitOverrides.get(pair) ?? row.priceUnit;
  const selectionKind = kindOverrides.get(pair) ?? row.kind;
  if (!['PIECE', 'M2'].includes(priceUnit)) throw new Error(`${pair} için onaylanmış fiyat birimi yok.`);
  if (!Number.isFinite(row.defaultPriceTry) || row.defaultPriceTry < 0) throw new Error(`${pair} için fiyat geçersiz.`);
  const tailoringNote = tailoringMappingsByPair.has(pair)
    ? `; terzi kalemi ${tailoringMappingsByPair.get(pair).map(index => index + 1).join(', ')}`
    : '';
  pairs.push({ ...row, priceUnit, selectionKind, tailoringNote });
}

writeFileSync(outputPath, buildCatalogSeed({ draft, decisions, pairs, excluded, guidFor }), 'utf8');
console.log(`${outputPath} üretildi: ${draft.categories.length} kategori, ${draft.products.length} ürün, ${draft.services.length} hizmet, ${pairs.length} aktif ürün/hizmet çifti.`);

// Usage: node docs/import-catalog.mjs "path/to/Pasted text.txt"
// Converts the supplied catalog text to reviewable seed data without guessing missing prices.
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const sourcePath = process.argv[2];
if (!sourcePath) throw new Error('Catalog text path is required');
const source = readFileSync(sourcePath, 'utf8').replace(/\s+/gu, ' ').trim();

const groups = [
  { code: 'DAILY', heading: '1. GÜNLÜK GİYİM', products: [
    'Gömlek', 'Bluz (Kumaş / İpek / Şifon)', 'Tişört / Polo Yaka',
    'Kazak / Triko / Hırka / Süveter', 'Sweatshirt / Hoodie', 'Pantolon (Kumaş / Kot)',
    'Etek', 'Pileli Etek', 'Günlük Elbise', 'Tulum / Salopet', 'Şort / Eşofman Altı',
  ] },
  { code: 'OUTERWEAR', heading: '2. DIŞ GİYİM', products: [
    'Ceket / Blazer', 'Kaban / Palto', 'Mont', 'Kaz / Kuş Tüyü Mont (Kısa)',
    'Kaz / Kuş Tüyü Kaban / Palto (Uzun)', 'Kaz / Kuş Tüyü Yelek / Şişme Yelek',
    'Trençkot / Pardösü', 'Hakiki Deri Ceket / Mont', 'Suni Deri Ceket / Mont',
    'Süet Ceket / Mont', 'Kürk (Hakiki)', 'Kürk (Suni)', 'Motorcu Montu',
  ] },
  { code: 'OCCASION', heading: '3. DAVET & ŞIK GİYİM', products: [
    'Takım Elbise (2 Parça)', 'Yelekli Takım Elbise (3 Parça)',
    'Abiye / Gece Elbisesi (Sade / Düz)', 'Abiye / Gece Elbisesi (Taşlı / Pullu / Şifon)',
    'Gelinlik (Sade / Düz)', 'Gelinlik (İşlemeli / Taşlı / Kuyruklu)',
    'Nişanlık / Kınalık / Kaftan', 'Duvak',
  ] },
  { code: 'HOME_TEXTILE', heading: '4. EV TEKSTİLİ', products: [
    'Elyaf Yorgan (Tek / Çift Kişilik)', 'Yün / Pamuk Yorgan', 'Kaz Tüyü Yorgan',
    'Battaniye', 'Battaniye (Büyük Boy)', 'Yatak Örtüsü (Sade)',
    'Yatak Örtüsü (Boncuklu/Taşlı/Güpürlü)', 'Tül Perde (m2)', 'Fon Perde (m2)',
    'Masa Örtüsü', 'Koltuk / Kırlent Kılıfı', 'Yastık (Elyaf / Tüy)',
  ] },
  { code: 'ACCESSORIES', heading: '5. AKSESUAR & DİĞER', products: [
    'Eşarp / Şal / Fular', 'Kravat / Papyon', 'Bez / Kumaş Spor Ayakkabı (Sneaker)',
    'Kasket / Şapka',
  ] },
];
const tailorHeading = '6. SADECE TERZİ & TADİLAT';
const sections = [...groups.map(group => group.heading), tailorHeading];
const sectionStarts = sections.map(heading => source.indexOf(heading));
if (sectionStarts.some((position, i) => position < 0 || (i && position <= sectionStarts[i - 1]))) {
  throw new Error('Category headings missing or out of order');
}

const servicePattern = /•\s*\[([x ])\]\s*([^:]+):\s*(\+?)([\d.]+)\s*TL/gu;
const parseServices = (segment, label) => {
  const rows = [...segment.matchAll(servicePattern)].map(match => ({
    name: match[2].trim(),
    defaultSelected: match[1] === 'x',
    isAddOn: match[3] === '+',
    price: Number(match[4].replaceAll('.', '')),
  }));
  const leftover = segment.replace(servicePattern, '').trim();
  if (!rows.length || leftover) throw new Error(`Unparsed content in ${label}: ${leftover}`);
  if (rows.some(row => !Number.isFinite(row.price))) throw new Error(`Invalid price in ${label}`);
  return rows;
};

const products = [];
const offerings = [];
const serviceIds = new Map();
let productNumber = 0;
for (let groupIndex = 0; groupIndex < groups.length; groupIndex++) {
  const group = groups[groupIndex];
  const section = source.slice(sectionStarts[groupIndex] + group.heading.length, sectionStarts[groupIndex + 1]).trim();
  const starts = group.products.map(name => {
    const marker = new RegExp(`${name.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&')}\\s*•\\s*\\[x\\]`, 'u');
    const position = section.search(marker);
    if (position < 0) throw new Error(`Missing product marker: ${name}`);
    return position;
  });
  if (starts[0] !== 0 || starts.some((position, i) => i && position <= starts[i - 1])) {
    throw new Error(`Product headings out of order in ${group.code}`);
  }
  for (let i = 0; i < group.products.length; i++) {
    const name = group.products[i];
    const productId = `P${String(++productNumber).padStart(3, '0')}`;
    const baseUnit = name.endsWith('(m2)') ? 'M2' : 'PIECE';
    products.push({ id: productId, categoryCode: group.code, name, baseUnit });
    const body = section.slice(starts[i] + name.length, starts[i + 1] ?? section.length).trim();
    const serviceRows = parseServices(body, name);
    if (serviceRows.filter(row => row.defaultSelected).length !== 1) {
      throw new Error(`Expected exactly one default service for ${name}`);
    }
    for (const row of serviceRows) {
      if (!serviceIds.has(row.name)) serviceIds.set(row.name, `S${String(serviceIds.size + 1).padStart(3, '0')}`);
      offerings.push({ productId, serviceId: serviceIds.get(row.name), defaultPriceTry: row.price,
        priceUnit: baseUnit === 'M2' && row.isAddOn ? null : baseUnit,
        defaultSelected: row.defaultSelected, kind: row.defaultSelected ? 'BASE' : row.isAddOn ? 'ADD_ON' : 'ALTERNATIVE' });
    }
  }
}

const tailorSection = source.slice(sectionStarts.at(-1) + tailorHeading.length);
const tailorIntro = 'Müşteri doğrudan bu kategoriye girdiğinde istediği tadilatı işaretler:';
if (!tailorSection.trimStart().startsWith(tailorIntro)) throw new Error('Tailor section intro changed');
const tailorRows = parseServices(tailorSection.trimStart().slice(tailorIntro.length).trim(), tailorHeading);

const catalog = {
  source: 'User-supplied catalog; prices in TRY',
  categories: groups.map(group => ({ code: group.code, name: group.heading.replace(/^\d+\. /u, '') })),
  products,
  services: [...serviceIds].map(([name, id]) => ({ id, name })),
  productServices: offerings,
  tailoringEntry: tailorRows,
};
const outputPath = resolve('docs/catalog-draft.json');
writeFileSync(outputPath, `${JSON.stringify(catalog, null, 2)}\n`, 'utf8');
console.log(`${outputPath}: ${catalog.categories.length} categories, ${products.length} products, ${catalog.services.length} distinct labels, ${offerings.length} product-service prices, ${tailorRows.length} tailoring entry prices`);

import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const contract = readFileSync(resolve(root, 'src/BuildingBlocks/GiysiGo.BuildingBlocks.Application/Contracts/PermissionCodes.cs'), 'utf8');
const permissions = [...contract.matchAll(/public const string \w+ = "([^"]+)";/g)].map(match => match[1]);
const roles = [ ['Customer', 'Müşteri', 'GLOBAL'], ['PlatformAdmin', 'Platform yöneticisi', 'GLOBAL'],
  ['CorporateOwner', 'Şirket sahibi', 'CORPORATE'], ['StoreManager', 'Dükkân yöneticisi', 'STORE'], ['StoreStaff', 'Dükkân personeli', 'STORE'] ];
const staff = new Set(['store.view', 'order.view', 'order.inspect', 'quote.prepare', 'order.process', 'order.fulfill']);
const scopedManagement = new Set([...staff, 'store.staff.manage', 'store.offering.manage', 'quote.approve']);
const quote = text => `N'${text.replaceAll("'", "''")}'`;
const guid = code => {
  const bytes = createHash('sha1').update(Buffer.from('c2ac3c89e4074c15ad3807b7b49d1114', 'hex')).update(code).digest().subarray(0, 16);
  bytes[6] = (bytes[6] & 15) | 80;
  bytes[8] = (bytes[8] & 63) | 128;
  const hex = bytes.toString('hex');
  return `${hex.slice(0,8)}-${hex.slice(8,12)}-${hex.slice(12,16)}-${hex.slice(16,20)}-${hex.slice(20)}`;
};
if (!permissions.includes('catalog.manage') || !permissions.includes('quote.prepare') || !permissions.includes('quote.approve'))
  throw new Error('Gerekli permission kodları ortak sözleşmede bulunamadı.');
const sql = ['-- docs/generate-identity-permission-seed.mjs tarafından üretilmiştir.',
  '-- Kullanıcı oluşturmaz veya kullanıcıya rol atamaz. Mevcut pasiflik ve iptaller korunur.',
  'SET XACT_ABORT ON;', 'BEGIN TRY', 'BEGIN TRANSACTION;'];
for (const [code, name, scope] of roles) {
  const id = guid(`role:${code}`);
  sql.push(`IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = ${quote(code)} AND (id <> '${id}' OR scope <> ${quote(scope)}))
    THROW 52100, N'Sabit rol kimliği veya kapsamı uyuşmuyor: ${code}.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles WHERE code = ${quote(code)})
    INSERT [identity].roles (id, code, name, scope) VALUES ('${id}', ${quote(code)}, ${quote(name)}, ${quote(scope)});`);
}
for (const permission of permissions) {
  const id = guid(`permission:${permission}`);
  sql.push(`IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = ${quote(permission)} AND id <> '${id}')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: ${permission}.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = ${quote(permission)})
    INSERT [identity].permissions (id, code, description) VALUES ('${id}', ${quote(permission)}, ${quote(`${permission} işlemi için sunucu izni`)});`);
  for (const [role] of roles) {
    const allowed = role === 'PlatformAdmin'
      || (['CorporateOwner', 'StoreManager'].includes(role) && scopedManagement.has(permission))
      || (role === 'StoreStaff' && staff.has(permission));
    if (!allowed) continue;
    sql.push(`IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '${guid(`role:${role}`)}' AND permission_id = '${id}')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('${guid(`grant:${role}:${permission}`)}', '${guid(`role:${role}`)}', '${id}');`);
  }
}
sql.push('COMMIT TRANSACTION;', 'END TRY', 'BEGIN CATCH', 'IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;', 'THROW;', 'END CATCH;', '');
writeFileSync(resolve(root, 'database/GiysiGo.Database/Scripts/IdentityPermissionsSeed.sql'), sql.join('\n'), 'utf8');
console.log(`Identity seed üretildi: ${roles.length} rol ve ${permissions.length} permission.`);

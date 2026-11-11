-- docs/generate-identity-permission-seed.mjs tarafından üretilmiştir.
-- Kullanıcı oluşturmaz veya kullanıcıya rol atamaz. Mevcut pasiflik ve iptaller korunur.
SET XACT_ABORT ON;
BEGIN TRY
BEGIN TRANSACTION;
IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'Customer' AND (id <> '02b218d8-2f8a-5237-aa59-7e1463e40715' OR scope <> N'GLOBAL'))
    THROW 52100, N'Sabit rol kimliği veya kapsamı uyuşmuyor: Customer.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'Customer')
    INSERT [identity].roles (id, code, name, scope) VALUES ('02b218d8-2f8a-5237-aa59-7e1463e40715', N'Customer', N'Müşteri', N'GLOBAL');
IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'PlatformAdmin' AND (id <> '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' OR scope <> N'GLOBAL'))
    THROW 52100, N'Sabit rol kimliği veya kapsamı uyuşmuyor: PlatformAdmin.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'PlatformAdmin')
    INSERT [identity].roles (id, code, name, scope) VALUES ('78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', N'PlatformAdmin', N'Platform yöneticisi', N'GLOBAL');
IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'CorporateOwner' AND (id <> '3222365a-af22-5e1c-9528-2d148915d707' OR scope <> N'CORPORATE'))
    THROW 52100, N'Sabit rol kimliği veya kapsamı uyuşmuyor: CorporateOwner.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'CorporateOwner')
    INSERT [identity].roles (id, code, name, scope) VALUES ('3222365a-af22-5e1c-9528-2d148915d707', N'CorporateOwner', N'Şirket sahibi', N'CORPORATE');
IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'StoreManager' AND (id <> '9bc01b77-c873-5b6b-829f-942b16b4ebc6' OR scope <> N'STORE'))
    THROW 52100, N'Sabit rol kimliği veya kapsamı uyuşmuyor: StoreManager.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'StoreManager')
    INSERT [identity].roles (id, code, name, scope) VALUES ('9bc01b77-c873-5b6b-829f-942b16b4ebc6', N'StoreManager', N'Dükkân yöneticisi', N'STORE');
IF EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'StoreStaff' AND (id <> 'e6d6590c-e813-5a50-9537-c01687f506b7' OR scope <> N'STORE'))
    THROW 52100, N'Sabit rol kimliği veya kapsamı uyuşmuyor: StoreStaff.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].roles WHERE code = N'StoreStaff')
    INSERT [identity].roles (id, code, name, scope) VALUES ('e6d6590c-e813-5a50-9537-c01687f506b7', N'StoreStaff', N'Dükkân personeli', N'STORE');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'catalog.manage' AND id <> '63a9905c-d427-51b7-9924-2fe02ee993bb')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: catalog.manage.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'catalog.manage')
    INSERT [identity].permissions (id, code, description) VALUES ('63a9905c-d427-51b7-9924-2fe02ee993bb', N'catalog.manage', N'catalog.manage işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = '63a9905c-d427-51b7-9924-2fe02ee993bb')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('17f67d34-28ff-5e3b-a155-c7fc61fc51ee', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', '63a9905c-d427-51b7-9924-2fe02ee993bb');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'store.view' AND id <> 'd079cbb7-a303-53e5-bc8a-a07ac4a67693')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: store.view.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'store.view')
    INSERT [identity].permissions (id, code, description) VALUES ('d079cbb7-a303-53e5-bc8a-a07ac4a67693', N'store.view', N'store.view işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = 'd079cbb7-a303-53e5-bc8a-a07ac4a67693')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('7b1ed8e2-1860-57be-b99f-ad1792d5c3ec', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', 'd079cbb7-a303-53e5-bc8a-a07ac4a67693');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = 'd079cbb7-a303-53e5-bc8a-a07ac4a67693')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('1eefcdfd-936a-5711-ad92-b14ab7f2512c', '3222365a-af22-5e1c-9528-2d148915d707', 'd079cbb7-a303-53e5-bc8a-a07ac4a67693');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = 'd079cbb7-a303-53e5-bc8a-a07ac4a67693')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('2b9e5edf-930b-50b6-8998-5b13f9db531f', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', 'd079cbb7-a303-53e5-bc8a-a07ac4a67693');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = 'e6d6590c-e813-5a50-9537-c01687f506b7' AND permission_id = 'd079cbb7-a303-53e5-bc8a-a07ac4a67693')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('d1e96c68-7651-511c-b331-1c2241e8e91e', 'e6d6590c-e813-5a50-9537-c01687f506b7', 'd079cbb7-a303-53e5-bc8a-a07ac4a67693');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'store.staff.manage' AND id <> 'b0c5169b-08ba-51e1-aef6-b7b156e22e35')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: store.staff.manage.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'store.staff.manage')
    INSERT [identity].permissions (id, code, description) VALUES ('b0c5169b-08ba-51e1-aef6-b7b156e22e35', N'store.staff.manage', N'store.staff.manage işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = 'b0c5169b-08ba-51e1-aef6-b7b156e22e35')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('4ccc7b86-a958-55c9-9a72-40762f0297af', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', 'b0c5169b-08ba-51e1-aef6-b7b156e22e35');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = 'b0c5169b-08ba-51e1-aef6-b7b156e22e35')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('6c58a737-ef62-5ddd-99a2-e3018442e54d', '3222365a-af22-5e1c-9528-2d148915d707', 'b0c5169b-08ba-51e1-aef6-b7b156e22e35');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = 'b0c5169b-08ba-51e1-aef6-b7b156e22e35')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('b2d3a9b5-ae74-5638-a505-f4033c11884e', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', 'b0c5169b-08ba-51e1-aef6-b7b156e22e35');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'store.offering.manage' AND id <> '577028a9-52f3-5229-9a46-7ef1bd6250f3')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: store.offering.manage.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'store.offering.manage')
    INSERT [identity].permissions (id, code, description) VALUES ('577028a9-52f3-5229-9a46-7ef1bd6250f3', N'store.offering.manage', N'store.offering.manage işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = '577028a9-52f3-5229-9a46-7ef1bd6250f3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('8014cbeb-9894-5680-9211-ea5b9becfe56', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', '577028a9-52f3-5229-9a46-7ef1bd6250f3');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = '577028a9-52f3-5229-9a46-7ef1bd6250f3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('e472dfd6-fa4d-5348-9807-bd71b3e43960', '3222365a-af22-5e1c-9528-2d148915d707', '577028a9-52f3-5229-9a46-7ef1bd6250f3');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = '577028a9-52f3-5229-9a46-7ef1bd6250f3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('154e2981-16b6-5ff0-979a-4f403e214ec4', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', '577028a9-52f3-5229-9a46-7ef1bd6250f3');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.view' AND id <> '08ccfd5f-6e04-5849-8e07-e79332e511e8')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: order.view.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.view')
    INSERT [identity].permissions (id, code, description) VALUES ('08ccfd5f-6e04-5849-8e07-e79332e511e8', N'order.view', N'order.view işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = '08ccfd5f-6e04-5849-8e07-e79332e511e8')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('93f15c56-24e6-5e5a-91b0-922c288e1730', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', '08ccfd5f-6e04-5849-8e07-e79332e511e8');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = '08ccfd5f-6e04-5849-8e07-e79332e511e8')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('8f75eb8e-5929-51a7-a54b-bc4c48848eeb', '3222365a-af22-5e1c-9528-2d148915d707', '08ccfd5f-6e04-5849-8e07-e79332e511e8');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = '08ccfd5f-6e04-5849-8e07-e79332e511e8')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('60605660-32f6-51f4-beaa-a5c83a3cac1a', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', '08ccfd5f-6e04-5849-8e07-e79332e511e8');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = 'e6d6590c-e813-5a50-9537-c01687f506b7' AND permission_id = '08ccfd5f-6e04-5849-8e07-e79332e511e8')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('a645c538-820a-587a-a253-bedede6d9e1e', 'e6d6590c-e813-5a50-9537-c01687f506b7', '08ccfd5f-6e04-5849-8e07-e79332e511e8');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.inspect' AND id <> '0233386f-8088-5806-a562-111ec704103f')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: order.inspect.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.inspect')
    INSERT [identity].permissions (id, code, description) VALUES ('0233386f-8088-5806-a562-111ec704103f', N'order.inspect', N'order.inspect işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = '0233386f-8088-5806-a562-111ec704103f')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('10a548c7-b52f-53b4-912a-f2bdc234247a', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', '0233386f-8088-5806-a562-111ec704103f');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = '0233386f-8088-5806-a562-111ec704103f')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('7864e808-df01-542d-b74d-a854779a2973', '3222365a-af22-5e1c-9528-2d148915d707', '0233386f-8088-5806-a562-111ec704103f');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = '0233386f-8088-5806-a562-111ec704103f')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('345a347a-42f7-5133-808b-78373642de5c', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', '0233386f-8088-5806-a562-111ec704103f');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = 'e6d6590c-e813-5a50-9537-c01687f506b7' AND permission_id = '0233386f-8088-5806-a562-111ec704103f')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('8f5847b2-00a7-5c59-b8d5-b150de38ba46', 'e6d6590c-e813-5a50-9537-c01687f506b7', '0233386f-8088-5806-a562-111ec704103f');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'quote.prepare' AND id <> 'e82958e6-d4da-5551-aa24-575692c54afd')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: quote.prepare.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'quote.prepare')
    INSERT [identity].permissions (id, code, description) VALUES ('e82958e6-d4da-5551-aa24-575692c54afd', N'quote.prepare', N'quote.prepare işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = 'e82958e6-d4da-5551-aa24-575692c54afd')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('8934e103-1b22-5426-97d0-2529ad21602c', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', 'e82958e6-d4da-5551-aa24-575692c54afd');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = 'e82958e6-d4da-5551-aa24-575692c54afd')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('925d36d4-f240-5d93-bb14-0fa3ca9c799d', '3222365a-af22-5e1c-9528-2d148915d707', 'e82958e6-d4da-5551-aa24-575692c54afd');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = 'e82958e6-d4da-5551-aa24-575692c54afd')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('3dfe2bfa-24bf-5540-aaf3-217328c6d64a', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', 'e82958e6-d4da-5551-aa24-575692c54afd');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = 'e6d6590c-e813-5a50-9537-c01687f506b7' AND permission_id = 'e82958e6-d4da-5551-aa24-575692c54afd')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('10b265f7-58b2-5d12-9180-1c531ee8ce84', 'e6d6590c-e813-5a50-9537-c01687f506b7', 'e82958e6-d4da-5551-aa24-575692c54afd');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'quote.approve' AND id <> 'd646be15-2cdf-540e-b768-e020fb3cfcff')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: quote.approve.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'quote.approve')
    INSERT [identity].permissions (id, code, description) VALUES ('d646be15-2cdf-540e-b768-e020fb3cfcff', N'quote.approve', N'quote.approve işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = 'd646be15-2cdf-540e-b768-e020fb3cfcff')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('42752346-7b01-50ef-9ff7-f1a4a78ddb0c', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', 'd646be15-2cdf-540e-b768-e020fb3cfcff');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = 'd646be15-2cdf-540e-b768-e020fb3cfcff')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('42d2c192-81de-51fe-ac4b-caefa745ff74', '3222365a-af22-5e1c-9528-2d148915d707', 'd646be15-2cdf-540e-b768-e020fb3cfcff');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = 'd646be15-2cdf-540e-b768-e020fb3cfcff')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('18928edc-ed87-50e6-a33a-73c5032a12d5', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', 'd646be15-2cdf-540e-b768-e020fb3cfcff');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.process' AND id <> '8bca0db5-4fc7-5cff-a529-93a5a839a65d')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: order.process.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.process')
    INSERT [identity].permissions (id, code, description) VALUES ('8bca0db5-4fc7-5cff-a529-93a5a839a65d', N'order.process', N'order.process işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = '8bca0db5-4fc7-5cff-a529-93a5a839a65d')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('73aaea12-5fa9-54b4-9abb-e9167fe32a9e', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', '8bca0db5-4fc7-5cff-a529-93a5a839a65d');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = '8bca0db5-4fc7-5cff-a529-93a5a839a65d')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('cfafa903-7754-54df-98f1-df3955c3c54f', '3222365a-af22-5e1c-9528-2d148915d707', '8bca0db5-4fc7-5cff-a529-93a5a839a65d');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = '8bca0db5-4fc7-5cff-a529-93a5a839a65d')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('bcedd30c-a027-54e0-9bc0-97f220d959c5', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', '8bca0db5-4fc7-5cff-a529-93a5a839a65d');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = 'e6d6590c-e813-5a50-9537-c01687f506b7' AND permission_id = '8bca0db5-4fc7-5cff-a529-93a5a839a65d')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('cec60563-9afc-506b-936b-4dd3ca8663b0', 'e6d6590c-e813-5a50-9537-c01687f506b7', '8bca0db5-4fc7-5cff-a529-93a5a839a65d');
IF EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.fulfill' AND id <> '1aa5de61-5836-52da-9eef-0a809e4e90a3')
    THROW 52100, N'Sabit permission kimliği uyuşmuyor: order.fulfill.', 1;
IF NOT EXISTS (SELECT 1 FROM [identity].permissions WHERE code = N'order.fulfill')
    INSERT [identity].permissions (id, code, description) VALUES ('1aa5de61-5836-52da-9eef-0a809e4e90a3', N'order.fulfill', N'order.fulfill işlemi için sunucu izni');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1' AND permission_id = '1aa5de61-5836-52da-9eef-0a809e4e90a3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('08134ff3-2a0e-5bf8-8b57-23fe6ffd5723', '78e6e4f5-a904-5b42-acdc-4f399cb6ffd1', '1aa5de61-5836-52da-9eef-0a809e4e90a3');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '3222365a-af22-5e1c-9528-2d148915d707' AND permission_id = '1aa5de61-5836-52da-9eef-0a809e4e90a3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('cb1291af-9eb1-52b5-9085-a253dfff01a4', '3222365a-af22-5e1c-9528-2d148915d707', '1aa5de61-5836-52da-9eef-0a809e4e90a3');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = '9bc01b77-c873-5b6b-829f-942b16b4ebc6' AND permission_id = '1aa5de61-5836-52da-9eef-0a809e4e90a3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('d14c20f3-db72-542b-9ef9-964abfc11c79', '9bc01b77-c873-5b6b-829f-942b16b4ebc6', '1aa5de61-5836-52da-9eef-0a809e4e90a3');
IF NOT EXISTS (SELECT 1 FROM [identity].role_permissions WHERE role_id = 'e6d6590c-e813-5a50-9537-c01687f506b7' AND permission_id = '1aa5de61-5836-52da-9eef-0a809e4e90a3')
    INSERT [identity].role_permissions (id, role_id, permission_id) VALUES ('9632744b-f5d6-586f-b6df-be4fc51325e4', 'e6d6590c-e813-5a50-9537-c01687f506b7', '1aa5de61-5836-52da-9eef-0a809e4e90a3');
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
THROW;
END CATCH;

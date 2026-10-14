# API controller sözleşmesi

Kaynak inceleme: Automation çözümünde CRUD tabanı `Stellar.Nexus.Service/Controllers/GenericControllerBase<T>` içindedir. `[ApiController]`, ortak kimlik/permission kontrolü ve tekrar eden yanıt davranışı fikirleri GiysiGO'ya uyarlandı. Basit kaynaklar generic CRUD kullanabilir; sipariş, teklif, ödeme ve teslimat komutları ayrı DTO ve application service kullanır.

`src/API/GiysiGo.API/Controllers` klasöründe her controller tabanı ayrı dosyadadır:

- `ApiControllerBase`: anonim kayıt/giriş gibi endpoint'ler için `[ApiController]` davranışı.
- `AuthenticatedApiControllerBase`: `[Authorize]` ve kimlik claim'inden `Guid` okuma yardımcısı. Türetilen controller kendi sabit route'unu yazar; örneğin `[Route("api/orders")]`.
- `RepositoryControllerBase<TEntity>`: `IRepository<TEntity>` bağımlılığını constructor üzerinden ortak şekilde alır. Basit entity controller'ları bunu kullanabilir. Kendisi HTTP endpoint'i açmaz; hangi CRUD işlemlerine izin verileceğini her modülün controller/application katmanı belirler.
- `GenericCrudControllerBase<TEntity>`: GET liste, GET kimlik, POST, PUT ve DELETE endpoint'lerini ekler. Her metot `virtual`'dır; controller davranışı değiştirmek için override edebilir, endpoint'i kaldırmak için `[NonAction]` ile override edebilir. `CanListAsync`, `CanReadAsync`, `CanCreateAsync`, `CanUpdateAsync` ve `CanDeleteAsync` kancaları varsayılan olarak erişimi reddeder; ilgili controller permission ve kayıt kapsamını doğrulayarak açar. `CanListAsync` yalnızca tüm kayıtları görmeye yetkili roller için açılır; kapsamlı liste gerekiyorsa `GetAll` override edilir.

Kimlik doğrulama şeması, token üretimi ve permission kapsamı Identity modülünde uygulanacak. Bir permission'ın varlığı tek başına yeterli değildir: müşteri yalnızca kendi kaydına, personel yalnızca atanmış şirket/dükkâna erişebilir. Generic CRUD kancaları bu denetimi çağırmalı; özel iş akışlarının controller'ları yalnızca DTO alıp application servisini çağırır. Kullanıcı, parola, ödeme ve sipariş gibi hassas entity'ler doğrudan generic POST/PUT gövdesi olarak kullanılmaz.

API host, `/health` ve geliştirme ortamında `/openapi/v1.json` sunar. Hatalar Problem Details biçiminde işlenir. `ConnectionStrings:GiysiGo` değeri üretim ortamında yapılandırma/secret üzerinden verilir. LocalDB örneği geliştirme ayarındadır. Yeni modüller controller'larını bu host'a bağlar.

using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Errors
{
    public static class ApiProblem
    {
        public static ProblemDetails Create(HttpContext context, int status, string? title = null, string? detail = null)
        {
            detail ??= DefaultDetail(status);
            ProblemDetails problem = status == 400
                ? new ValidationProblemDetails(new Dictionary<string, string[]> { ["request"] = [detail] })
                : new ProblemDetails();
            problem.Status = status;
            problem.Title = title;
            problem.Detail = detail;
            Complete(context, problem);
            return problem;
        }

        // MVC nesne sonuçları ve IProblemDetailsService aynı sözleşmeyi kullanır.
        public static void Complete(HttpContext context, ProblemDetails problem)
        {
            var status = problem.Status ?? 500;
            problem.Status = status;
            problem.Type ??= "about:blank";
            problem.Title ??= status switch
            {
                400 => "İstek bilgileri geçersiz.", 401 => "Kimlik doğrulaması gerekli.",
                403 => "Bu işlem için yetkiniz yok.", 404 => "Kayıt bulunamadı.",
                409 => "İşlem mevcut durumla çelişiyor.", _ => "İstek tamamlanamadı."
            };
            problem.Detail ??= DefaultDetail(status);
            problem.Instance ??= context.Request.Path.HasValue ? context.Request.Path.Value : "/";
            problem.Extensions.TryAdd("code", status switch
            {
                400 => "validation_failed", 401 => "authentication_required", 403 => "permission_denied",
                404 => "resource_not_found", 405 => "method_not_allowed", 409 => "state_conflict", _ => "unexpected_error"
            });
            problem.Extensions.TryAdd("traceId", context.TraceIdentifier);
            if (status >= 500)
            {
                problem.Title = "Beklenmeyen bir hata oluştu.";
                problem.Detail = DefaultDetail(status);
            }
        }

        private static string DefaultDetail(int status) => status switch
        {
            400 => "Gönderilen bilgileri ve istek parametrelerini kontrol edin.",
            401 => "Geçerli bir erişim token'ı gerekli.",
            403 => "Bu işlem için gerekli izin bulunmuyor.",
            404 => "İstenen kaynak bu kapsamda bulunamadı.",
            409 => "Kayıt zaten var veya işlem mevcut durumla çelişiyor.",
            _ => "İşlem tamamlanamadı. Takip kimliğiyle destek isteyebilirsiniz."
        };
    }
}

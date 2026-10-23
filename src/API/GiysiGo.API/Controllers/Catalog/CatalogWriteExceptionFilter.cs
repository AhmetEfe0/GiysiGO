using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.Controllers.Catalog
{
    public sealed class CatalogWriteExceptionFilter : IExceptionFilter
    {
        public void OnException(ExceptionContext context)
        {
            if (context.Exception is not SqlException sql) return;
            var status = sql.Number switch { 52200 => 400, 52201 => 404, 52202 or 2601 or 2627 => 409, _ => 0 };
            if (status == 0) return;
            var code = status switch { 400 => "validation_failed", 404 => "resource_not_found", _ => "state_conflict" };
            var problem = new ProblemDetails
            {
                Status = status,
                Title = status switch { 400 => "Geçersiz katalog bilgileri.", 404 => "Kayıt veya uygun üst kayıt bulunamadı.", _ => "Kayıt zaten var veya işlem mevcut durumla çelişiyor." },
                Instance = context.HttpContext.Request.Path
            };
            problem.Extensions["code"] = code;
            problem.Extensions["traceId"] = context.HttpContext.TraceIdentifier;
            context.Result = new ObjectResult(problem) { StatusCode = status, ContentTypes = { "application/problem+json" } };
            context.ExceptionHandled = true;
        }
    }
}

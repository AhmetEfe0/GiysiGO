using GiysiGo.API.Errors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.Controllers.Identity
{
    public sealed class StaffExceptionFilter : IExceptionFilter
    {
        public void OnException(ExceptionContext context)
        {
            if (context.Exception is UnauthorizedAccessException)
            {
                context.Result = new ForbidResult();
                context.ExceptionHandled = true;
                return;
            }
            var status = context.Exception switch
            {
                ArgumentException => 400,
                KeyNotFoundException => 404,
                SqlException { Number: 51001 } => 404,
                SqlException { Number: 51002 } => 400,
                SqlException { Number: 2601 or 2627 } => 409,
                _ => 0
            };
            if (status == 0) return;
            context.Result = new ObjectResult(ApiProblem.Create(context.HttpContext, status))
            { StatusCode = status, ContentTypes = { "application/problem+json" } };
            context.ExceptionHandled = true;
        }
    }
}

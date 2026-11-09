using GiysiGo.API.Errors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.Controllers.Stores
{
    public sealed class StoreExceptionFilter : IExceptionFilter
    {
        public void OnException(ExceptionContext context)
        {
            var status = context.Exception switch
            {
                UnauthorizedAccessException => 403,
                KeyNotFoundException => 404,
                ArgumentException => 400,
                SqlException { Number: 52300 } => 400,
                SqlException { Number: 52301 } => 404,
                SqlException { Number: 52302 or 2601 or 2627 } => 409,
                _ => 0
            };
            if (status == 0) return;
            context.Result = new ObjectResult(ApiProblem.Create(context.HttpContext, status)) { StatusCode = status, ContentTypes = { "application/problem+json" } };
            context.ExceptionHandled = true;
        }
    }
}

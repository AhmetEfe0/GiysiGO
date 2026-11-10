namespace GiysiGo.API.Authorization
{
    public static class SecurityProblem
    {
        public static Task WriteAsync(HttpContext context, int statusCode, string code, string detail)
            => Results.Problem(statusCode: statusCode,
                title: statusCode == 401 ? "Kimlik doğrulaması gerekli." : "Bu işlem için yetkiniz yok.",
                detail: detail, instance: context.Request.Path,
                extensions: new Dictionary<string, object?> { ["code"] = code, ["traceId"] = context.TraceIdentifier })
                .ExecuteAsync(context);
    }
}

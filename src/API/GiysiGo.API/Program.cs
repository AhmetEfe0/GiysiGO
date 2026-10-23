using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.BuildingBlocks.Application.Events;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Infrastructure;
using GiysiGo.Modules.Catalog.Infrastructure;
using GiysiGo.Modules.Ordering.Infrastructure;
using GiysiGo.Modules.Operations.Infrastructure;
using GiysiGo.API.Authorization;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers().ConfigureApiBehaviorOptions(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var problem = new Microsoft.AspNetCore.Mvc.ValidationProblemDetails(context.ModelState)
        {
            Status = 400, Title = "İstek bilgileri geçersiz.", Instance = context.HttpContext.Request.Path
        };
        problem.Extensions["code"] = "validation_failed";
        problem.Extensions["traceId"] = context.HttpContext.TraceIdentifier;
        return new Microsoft.AspNetCore.Mvc.BadRequestObjectResult(problem);
    };
});
builder.Services.AddProblemDetails(options => options.CustomizeProblemDetails = context =>
{
    var status = context.ProblemDetails.Status ?? 500;
    context.ProblemDetails.Extensions.TryAdd("traceId", context.HttpContext.TraceIdentifier);
    context.ProblemDetails.Extensions.TryAdd("code", status switch
    {
        400 => "validation_failed", 401 => "authentication_required", 403 => "permission_denied",
        404 => "resource_not_found", 405 => "method_not_allowed", 409 => "state_conflict", _ => "unexpected_error"
    });
    if (status >= 500)
    {
        context.ProblemDetails.Title = "Beklenmeyen bir hata oluştu.";
        context.ProblemDetails.Detail = "İşlem tamamlanamadı. Takip kimliğiyle destek isteyebilirsiniz.";
    }
});
builder.Services.AddIdentityAuthentication(builder.Configuration);
builder.Services.AddOpenApi();
builder.Services.AddHealthChecks();
builder.Services.AddIdentityModule();
builder.Services.AddCatalogModule();
builder.Services.AddOrderingModule();
builder.Services.AddOperationsModule();
builder.Services.AddScoped<ITransactionRunner, SqlTransactionRunner>();
builder.Services.AddScoped<IOutboxWriter, SqlOutboxWriter>();
builder.Services.AddScoped<IOutboxDispatcher, SqlOutboxDispatcher>();

builder.Services.AddSingleton(_ =>
{
    var connectionString = builder.Configuration.GetConnectionString("GiysiGo")
        ?? throw new InvalidOperationException("ConnectionStrings:GiysiGo is required.");
    return new SqlConnectionFactory(connectionString);
});

var app = builder.Build();

app.UseExceptionHandler();
app.UseStatusCodePages(async context =>
{
    var http = context.HttpContext;
    await Results.Problem(statusCode: http.Response.StatusCode,
        title: http.Response.StatusCode == 404 ? "Kayıt bulunamadı." : "İstek tamamlanamadı.",
        instance: http.Request.Path).ExecuteAsync(http);
});

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

app.Run();

public partial class Program;

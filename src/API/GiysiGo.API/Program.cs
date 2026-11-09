using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.BuildingBlocks.Application.Events;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Infrastructure;
using GiysiGo.Modules.Catalog.Infrastructure;
using GiysiGo.Modules.Ordering.Infrastructure;
using GiysiGo.Modules.Operations.Infrastructure;
using GiysiGo.API.Authorization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Policy;
using GiysiGo.API.Errors;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers().ConfigureApiBehaviorOptions(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var problem = new ValidationProblemDetails(context.ModelState) { Status = 400 };
        ApiProblem.Complete(context.HttpContext, problem);
        return new BadRequestObjectResult(problem) { ContentTypes = { "application/problem+json" } };
    };
});
builder.Services.AddProblemDetails(options => options.CustomizeProblemDetails = context => ApiProblem.Complete(context.HttpContext, context.ProblemDetails));
builder.Services.AddAuthentication();
builder.Services.AddAuthorization(PermissionPolicies.AddPermissionPolicies);
builder.Services.AddScoped<IAuthorizationHandler, PermissionAuthorizationHandler>();
builder.Services.AddSingleton<IAuthorizationMiddlewareResultHandler, ProblemDetailsAuthorizationResultHandler>();
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
app.UseStatusCodePages(async context => await Results.Problem(statusCode: context.HttpContext.Response.StatusCode).ExecuteAsync(context.HttpContext));

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

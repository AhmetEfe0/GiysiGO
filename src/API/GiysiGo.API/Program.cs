using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.BuildingBlocks.Application.Events;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Infrastructure;
using GiysiGo.Modules.Catalog.Infrastructure;
using GiysiGo.Modules.Ordering.Infrastructure;
using GiysiGo.Modules.Operations.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddProblemDetails();
builder.Services.AddAuthentication();
builder.Services.AddAuthorization();
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

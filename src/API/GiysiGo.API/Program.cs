using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.BuildingBlocks.Application.Events;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Infrastructure;
using GiysiGo.Modules.Catalog.Infrastructure;
using GiysiGo.Modules.Ordering.Infrastructure;
using GiysiGo.Modules.Operations.Infrastructure;
using GiysiGo.API.Authorization;
using GiysiGo.API.Authentication;
using GiysiGo.Modules.Identity.Application.Interfaces.Authentication;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Policy;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddProblemDetails();
builder.Services.Configure<ApiBehaviorOptions>(options => options.InvalidModelStateResponseFactory = context =>
{
    var problem = new ValidationProblemDetails(context.ModelState)
    {
        Type = "https://httpstatuses.io/400",
        Title = "Bad Request",
        Status = StatusCodes.Status400BadRequest,
        Detail = "Request validation failed.",
        Instance = context.HttpContext.Request.Path
    };
    problem.Extensions["code"] = "validation_error";
    problem.Extensions["traceId"] = context.HttpContext.TraceIdentifier;
    var response = new ObjectResult(problem) { StatusCode = StatusCodes.Status400BadRequest };
    response.ContentTypes.Add("application/problem+json");
    return response;
});
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.MapInboundClaims = false;
        var jwt = builder.Configuration.GetSection("Jwt");
        var key = jwt["SigningKey"];
        if (string.IsNullOrWhiteSpace(key) || Encoding.UTF8.GetByteCount(key) < 32)
            throw new InvalidOperationException("Jwt:SigningKey must be at least 32 UTF-8 bytes.");
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwt["Issuer"],
            ValidateAudience = true,
            ValidAudience = jwt["Audience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero,
            NameClaimType = "sub"
        };
        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = async context =>
            {
                if (!Guid.TryParse(context.Principal?.FindFirstValue("sub"), out var userId)
                    || userId == Guid.Empty)
                {
                    context.Fail("Invalid user identifier.");
                    return;
                }
                var transactions = context.HttpContext.RequestServices.GetRequiredService<ITransactionRunner>();
                var users = context.HttpContext.RequestServices.GetRequiredService<IUserRepository>();
                var active = await transactions.ExecuteAsync(async (connection, transaction, token) =>
                {
                    var user = await users.GetByIdAsync(userId, connection, transaction, token);
                    return user is { IsActive: true, DeleteDate: null };
                }, context.HttpContext.RequestAborted);
                if (!active)
                {
                    context.Fail("User account is inactive.");
                    return;
                }
                if (context.Principal?.Identity is not ClaimsIdentity identity)
                {
                    context.Fail("Invalid identity.");
                    return;
                }
                var nameIdentifier = identity.FindFirst(ClaimTypes.NameIdentifier);
                if (nameIdentifier is not null && nameIdentifier.Value != userId.ToString())
                {
                    context.Fail("Conflicting user identifier.");
                    return;
                }
                if (nameIdentifier is null)
                    identity.AddClaim(new Claim(ClaimTypes.NameIdentifier, userId.ToString()));
            }
        };
    });
builder.Services.AddSingleton<IAccessTokenIssuer, JwtAccessTokenIssuer>();
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

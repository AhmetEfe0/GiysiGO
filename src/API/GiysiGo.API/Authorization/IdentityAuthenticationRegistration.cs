using System.Security.Claims;
using System.Text;
using GiysiGo.BuildingBlocks.Application.Contracts;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;

namespace GiysiGo.API.Authorization
{
    public static class IdentityAuthenticationRegistration
    {
        public static IServiceCollection AddIdentityAuthentication(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
            {
                var key = configuration["Jwt:SigningKey"];
                options.MapInboundClaims = false;
                options.IncludeErrorDetails = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = configuration["Jwt:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = configuration["Jwt:Audience"],
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = !string.IsNullOrEmpty(key) && Encoding.UTF8.GetByteCount(key) >= 32
                        ? new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)) : null,
                    ValidAlgorithms = [SecurityAlgorithms.HmacSha256],
                    RequireSignedTokens = true,
                    RequireExpirationTime = true,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    NameClaimType = ClaimTypes.NameIdentifier
                };
                options.Events = new JwtBearerEvents
                {
                    OnTokenValidated = async context =>
                    {
                        var subjects = context.Principal!.FindAll("sub").ToArray();
                        if (subjects.Length != 1 || !Guid.TryParse(subjects[0].Value, out var userId) || userId == Guid.Empty)
                        {
                            context.Fail("Geçerli bir kullanıcı kimliği gerekli.");
                            return;
                        }
                        var services = context.HttpContext.RequestServices;
                        var users = services.GetRequiredService<IUserRepository>();
                        var active = await services.GetRequiredService<ITransactionRunner>().ExecuteAsync(async (connection, transaction, token) =>
                        {
                            var user = await users.GetByIdAsync(userId, connection, transaction, token);
                            return user is { IsActive: true, DeleteDate: null };
                        }, context.HttpContext.RequestAborted);
                        if (!active)
                        {
                            context.Fail("Kullanıcı aktif değil.");
                            return;
                        }
                        var identity = (ClaimsIdentity)context.Principal.Identity!;
                        foreach (var claim in identity.FindAll(ClaimTypes.NameIdentifier).ToArray()) identity.RemoveClaim(claim);
                        identity.AddClaim(new Claim(ClaimTypes.NameIdentifier, userId.ToString()));
                    },
                    OnChallenge = async context =>
                    {
                        context.HandleResponse();
                        context.Response.Headers.WWWAuthenticate = "Bearer";
                        await SecurityProblem.WriteAsync(context.HttpContext, 401, "authentication_required", "Geçerli bir erişim token'ı gerekli.");
                    },
                    OnForbidden = context => SecurityProblem.WriteAsync(context.HttpContext, 403, "permission_denied", "Bu işlem için gerekli izin bulunmuyor.")
                };
            });
            services.AddAuthorization(options => options.AddPolicy(PermissionCodes.CatalogManage, policy =>
                policy.RequireAuthenticatedUser().AddRequirements(new PermissionRequirement(PermissionCodes.CatalogManage))));
            services.AddScoped<IAuthorizationHandler, PermissionAuthorizationHandler>();
            return services;
        }
    }
}

using System.Net.Http.Json;
using System.Text.RegularExpressions;
using Dapper;
using GiysiGo.API.Controllers.Stores;
using GiysiGo.BuildingBlocks.Application.Transactions;
using GiysiGo.BuildingBlocks.Infrastructure;
using GiysiGo.Modules.Identity.Application.Interfaces.Repositories;
using GiysiGo.Modules.Identity.Domain.Entities;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.DependencyInjection;

namespace GiysiGo.API.IntegrationTests
{
    public sealed class StoreTestDatabase : IAsyncDisposable
    {
        private readonly List<Guid> corporates = [];
        private readonly List<Guid> users = [];
        private readonly WebApplicationFactory<Program> application;
        private readonly IServiceScope scope;
        public StoreTestDatabase(Action<IServiceCollection>? configureServices = null)
        {
            var configuration = new SqlConnectionStringBuilder(Environment.GetEnvironmentVariable("GIYSIGO_STORE_TEST_CONNECTION"));
            if (!Regex.IsMatch(configuration.InitialCatalog, "^GiysiGo_IdentityTest_[a-f0-9]{32}$")) throw new InvalidOperationException("Yalnız ayrılmış test veritabanı kullanılabilir.");
            Connections = new SqlConnectionFactory(configuration.ConnectionString);
            application = new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder.ConfigureTestServices(services =>
            {
                services.AddSingleton(Connections);
                // Yalnız HTTP kimlik doğrulaması test şemasıdır; Identity checker/repository ve Catalog okuyucuları gerçektir.
                services.AddAuthentication(options => { options.DefaultAuthenticateScheme = "Test"; options.DefaultChallengeScheme = "Test"; })
                    .AddScheme<AuthenticationSchemeOptions, TestAuthenticationHandler>("Test", _ => { });
                configureServices?.Invoke(services);
            }));
            Client = application.CreateClient();
            scope = application.Services.CreateScope();
        }
        public SqlConnectionFactory Connections { get; }
        public HttpClient Client { get; }
        public T Get<T>() where T : notnull => scope.ServiceProvider.GetRequiredService<T>();
        public void ActAs(Guid? userId)
        {
            Client.DefaultRequestHeaders.Remove("X-Test-User");
            if (userId.HasValue) Client.DefaultRequestHeaders.Add("X-Test-User", userId.ToString());
        }
        public async Task<Guid> CorporateAsync()
        {
            var id = await Get<ICorporateRepository>().InsertAsync(new Corporate { Name = "Dükkân yönetimi testi" });
            corporates.Add(id); return id;
        }
        public async Task<Guid> UserAsync(string roleCode, Guid? corporateId = null, Guid? storeId = null)
        {
            return await Get<ITransactionRunner>().ExecuteAsync(async (connection, transaction, token) =>
            {
                var userId = await Get<IUserRepository>().InsertAsync(new User { Email = Guid.NewGuid().ToString("N") + "@example.test", PasswordHash = "yalnız-test" }, connection, transaction, token);
                users.Add(userId);
                var roleId = (await Get<IRoleRepository>().GetAllAsync()).Single(role => role.Code == roleCode).Id;
                var access = Get<IIdentityAccessRepository>();
                if (corporateId.HasValue) await access.GrantCorporateMembershipAsync(userId, corporateId.Value, roleId, connection, transaction, token);
                else if (storeId.HasValue) await access.GrantStoreAssignmentAsync(userId, storeId.Value, roleId, connection, transaction, token);
                else await access.GrantUserRoleAsync(userId, roleId, connection, transaction, token);
                return userId;
            });
        }
        public static object ValidRequest(string name = "Merkez") => new { name, addressText = "Örnek adres", latitude = 41m, longitude = 29m, serviceRadiusKm = 5m };
        public static string Path(Guid corporateId, Guid? id = null) => $"/corporates/{corporateId}/stores" + (id.HasValue ? $"/{id}" : "");
        public async Task<Guid> CreateAsync(Guid corporateId, string name = "Merkez")
        {
            using var response = await Client.PostAsJsonAsync(Path(corporateId), ValidRequest(name));
            Assert.True(response.StatusCode == System.Net.HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
            var result = await response.Content.ReadFromJsonAsync<StoreCreatedDto>();
            Assert.NotNull(result); Assert.NotEqual(Guid.Empty, result.Id);
            Assert.Equal(Path(corporateId, result.Id), response.Headers.Location?.AbsolutePath);
            return result.Id;
        }
        public async Task ExecuteAsync(string fixture, object parameters)
        {
            await using var connection = await Connections.OpenAsync();
            await connection.ExecuteAsync(await File.ReadAllTextAsync(System.IO.Path.Combine(AppContext.BaseDirectory, "Fixtures", fixture)), parameters);
        }
        public async ValueTask DisposeAsync()
        {
            try { await ExecuteAsync("CleanupStoreManagementFixture.sql", new { CorporateIds = corporates.ToArray(), UserIds = users.ToArray() }); }
            finally { scope.Dispose(); Client.Dispose(); await application.DisposeAsync(); }
        }
    }
}

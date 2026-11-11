using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using GiysiGo.Modules.Ordering.Infrastructure.Storage;

namespace GiysiGo.Modules.Ordering.Tests
{
    public sealed class LocalCartPhotoStorageTests : IDisposable
    {
        private readonly string _contentRoot = Path.Combine(Path.GetTempPath(), "giysigo-cart-photo-tests", Guid.NewGuid().ToString("N"));
        private readonly FakeWebHostEnvironment _environment;
        private readonly LocalCartPhotoStorage _storage;

        public LocalCartPhotoStorageTests()
        {
            _environment = new FakeWebHostEnvironment(_contentRoot, Environments.Development);
            _storage = new LocalCartPhotoStorage(_environment);
        }

        [Fact]
        public async Task Stores_and_reads_png_by_generated_storage_key()
        {
            var bytes = new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 0, 42 };
            await using var input = new MemoryStream(bytes);

            var storageKey = await _storage.StoreAsync(input);
            var stored = await _storage.OpenReadAsync(storageKey);

            Assert.EndsWith(".png", storageKey, StringComparison.Ordinal);
            Assert.NotNull(stored);
            Assert.Equal("image/png", stored!.ContentType);
            await using var output = new MemoryStream();
            await stored.Content.CopyToAsync(output);
            Assert.Equal(bytes, output.ToArray());
        }

        [Fact]
        public async Task Rejects_non_image_content_and_path_traversal()
        {
            await using var input = new MemoryStream("not an image"u8.ToArray());
            await Assert.ThrowsAsync<InvalidDataException>(() => _storage.StoreAsync(input));
            await Assert.ThrowsAsync<ArgumentException>(() => _storage.OpenReadAsync("../secret.jpg"));
        }

        [Fact]
        public async Task Rejects_photos_larger_than_ten_megabytes()
        {
            var bytes = new byte[10 * 1024 * 1024 + 1];
            new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 }.CopyTo(bytes, 0);
            await using var input = new MemoryStream(bytes);

            await Assert.ThrowsAsync<InvalidDataException>(() => _storage.StoreAsync(input));
        }

        [Fact]
        public async Task Local_storage_is_disabled_outside_development()
        {
            var productionStorage = new LocalCartPhotoStorage(new FakeWebHostEnvironment(_contentRoot, Environments.Production));
            await using var input = new MemoryStream(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 });

            await Assert.ThrowsAsync<InvalidOperationException>(() => productionStorage.StoreAsync(input));
        }

        public void Dispose()
        {
            if (Directory.Exists(_contentRoot))
                Directory.Delete(_contentRoot, recursive: true);
        }

        private sealed class FakeWebHostEnvironment(string contentRoot, string environmentName) : IWebHostEnvironment
        {
            public string ApplicationName { get; set; } = "GiysiGo.Tests";
            public IFileProvider WebRootFileProvider { get; set; } = new NullFileProvider();
            public string WebRootPath { get; set; } = contentRoot;
            public string EnvironmentName { get; set; } = environmentName;
            public string ContentRootPath { get; set; } = contentRoot;
            public IFileProvider ContentRootFileProvider { get; set; } = new NullFileProvider();
        }
    }
}

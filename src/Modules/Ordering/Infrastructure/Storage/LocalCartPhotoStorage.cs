using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using GiysiGo.Modules.Ordering.Application.Contracts;

namespace GiysiGo.Modules.Ordering.Infrastructure.Storage
{
    public sealed class LocalCartPhotoStorage(IWebHostEnvironment environment) : ICartPhotoStorage
    {
        private const long MaximumPhotoBytes = 10 * 1024 * 1024;
        private readonly string _rootPath = Path.Combine(environment.ContentRootPath, "App_Data", "cart-photos");

        public async Task<string> StoreAsync(Stream content, CancellationToken cancellationToken = default)
        {
            EnsureDevelopmentOnly();
            ArgumentNullException.ThrowIfNull(content);
            Directory.CreateDirectory(_rootPath);

            var fileId = $"{Guid.NewGuid():N}";
            var temporaryPath = Path.Combine(_rootPath, fileId + ".tmp");
            try
            {
                (string Extension, string ContentType)? imageType;
                await using (var output = new FileStream(temporaryPath, FileMode.CreateNew, FileAccess.Write, FileShare.None, 81920, useAsync: true))
                {
                    var prefix = new byte[12];
                    var prefixLength = await ReadPrefixAsync(content, prefix, cancellationToken);
                    imageType = DetectImageType(prefix.AsSpan(0, prefixLength));
                    if (imageType is null)
                        throw new InvalidDataException("Only valid JPEG, PNG, or WebP image files are accepted.");

                    await output.WriteAsync(prefix.AsMemory(0, prefixLength), cancellationToken);
                    var buffer = new byte[81920];
                    long totalBytes = prefixLength;
                    int bytesRead;
                    while ((bytesRead = await content.ReadAsync(buffer, cancellationToken)) > 0)
                    {
                        totalBytes += bytesRead;
                        if (totalBytes > MaximumPhotoBytes)
                            throw new InvalidDataException("Cart photos cannot exceed 10 MB.");
                        await output.WriteAsync(buffer.AsMemory(0, bytesRead), cancellationToken);
                    }
                }

                var storageKey = fileId + imageType.Value.Extension;
                File.Move(temporaryPath, GetPath(storageKey));
                return storageKey;
            }
            catch
            {
                if (File.Exists(temporaryPath))
                    File.Delete(temporaryPath);
                throw;
            }
        }

        public Task<StoredCartPhoto?> OpenReadAsync(string storageKey, CancellationToken cancellationToken = default)
        {
            EnsureDevelopmentOnly();
            cancellationToken.ThrowIfCancellationRequested();
            var path = GetPath(storageKey);
            if (!File.Exists(path))
                return Task.FromResult<StoredCartPhoto?>(null);
            var contentType = Path.GetExtension(path).ToLowerInvariant() switch
            {
                ".jpg" => "image/jpeg",
                ".png" => "image/png",
                ".webp" => "image/webp",
                _ => throw new InvalidDataException("Unsupported stored photo type.")
            };
            return Task.FromResult<StoredCartPhoto?>(new StoredCartPhoto(
                new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read, 81920, useAsync: true), contentType));
        }

        public Task DeleteAsync(string storageKey, CancellationToken cancellationToken = default)
        {
            EnsureDevelopmentOnly();
            cancellationToken.ThrowIfCancellationRequested();
            var path = GetPath(storageKey);
            if (File.Exists(path))
                File.Delete(path);
            return Task.CompletedTask;
        }

        private string GetPath(string storageKey)
        {
            if (string.IsNullOrWhiteSpace(storageKey) || storageKey.Length > 64
                || storageKey != Path.GetFileName(storageKey)
                || !Guid.TryParseExact(Path.GetFileNameWithoutExtension(storageKey), "N", out _)
                || Path.GetExtension(storageKey).ToLowerInvariant() is not (".jpg" or ".png" or ".webp"))
                throw new ArgumentException("Invalid cart photo storage key.", nameof(storageKey));
            return Path.Combine(_rootPath, storageKey);
        }

        private static async Task<int> ReadPrefixAsync(Stream content, byte[] prefix, CancellationToken cancellationToken)
        {
            var count = 0;
            while (count < prefix.Length)
            {
                var read = await content.ReadAsync(prefix.AsMemory(count, prefix.Length - count), cancellationToken);
                if (read == 0)
                    break;
                count += read;
            }
            return count;
        }

        private static (string Extension, string ContentType)? DetectImageType(ReadOnlySpan<byte> bytes)
        {
            if (bytes.Length >= 3 && bytes[0] == 0xff && bytes[1] == 0xd8 && bytes[2] == 0xff)
                return (".jpg", "image/jpeg");
            if (bytes.Length >= 8 && bytes[..8].SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 }))
                return (".png", "image/png");
            if (bytes.Length >= 12 && bytes[..4].SequenceEqual("RIFF"u8) && bytes[8..12].SequenceEqual("WEBP"u8))
                return (".webp", "image/webp");
            return null;
        }

        private void EnsureDevelopmentOnly()
        {
            if (!environment.IsDevelopment())
                throw new InvalidOperationException("Local cart photo storage is available only in Development.");
        }
    }
}

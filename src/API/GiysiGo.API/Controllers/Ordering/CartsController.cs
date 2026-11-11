using System.ComponentModel.DataAnnotations;
using GiysiGo.API.Controllers;
using GiysiGo.Modules.Ordering.Application.Contracts;
using GiysiGo.Modules.Ordering.Domain;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers.Ordering
{
    [Route("carts")]
    public sealed class CartsController(
        ICartCommandService carts,
        ICartQueryService cartQueries,
        ICartPhotoStorage photoStorage) : AuthenticatedApiControllerBase
    {
        [HttpGet("{cartId:guid}")]
        public async Task<IActionResult> GetOpenCart(Guid cartId, CancellationToken cancellationToken)
        {
            var cart = await cartQueries.GetOpenCartAsync(cartId, cancellationToken);
            return cart is null ? NotFound() : Ok(cart);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCartRequest request, CancellationToken cancellationToken)
        {
            var cartId = await carts.CreateAsync(request.StoreId, request.AddressId, request.PickupWindowStartUtc, request.PickupWindowEndUtc, cancellationToken);
            return CreatedAtAction(nameof(GetOpenCart), new { cartId }, new { cartId });
        }

        [HttpPost("{cartId:guid}/items")]
        public async Task<IActionResult> AddItem(Guid cartId, [FromBody] AddCartItemRequest request, CancellationToken cancellationToken)
        {
            var item = new CartItem
            {
                Id = Guid.NewGuid(), CartId = cartId, ProductTypeId = request.ProductTypeId,
                CustomerNote = request.CustomerNote, CustomerMeasurement = request.CustomerMeasurement
            };
            await carts.AddItemAsync(item, request.ExpectedCartVersion, cancellationToken);
            return Ok(new { itemId = item.Id });
        }

        [HttpPost("{cartId:guid}/items/{itemId:guid}/services")]
        public async Task<IActionResult> AddService(Guid cartId, Guid itemId, [FromBody] AddCartServiceRequest request, CancellationToken cancellationToken)
        {
            var service = new CartItemService { Id = Guid.NewGuid(), CartItemId = itemId, StoreOfferingId = request.StoreOfferingId };
            await carts.AddServiceAsync(service, request.ServiceId, request.ExpectedCartVersion, cancellationToken);
            return Ok(new { serviceId = service.Id });
        }

        [HttpPost("{cartId:guid}/items/{itemId:guid}/photos")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> AddPhoto(
            Guid cartId,
            Guid itemId,
            [FromQuery, Range(0, int.MaxValue)] int expectedCartVersion,
            [FromForm] IFormFile file,
            CancellationToken cancellationToken)
        {
            if (file is null || file.Length is <= 0 or > 10 * 1024 * 1024)
                return BadRequest(new ProblemDetails { Title = "Invalid photo", Detail = "Photo size must be between 1 byte and 10 MB." });

            await using var content = file.OpenReadStream();
            string storageKey;
            try
            {
                storageKey = await photoStorage.StoreAsync(content, cancellationToken);
            }
            catch (InvalidDataException exception)
            {
                return BadRequest(new ProblemDetails { Title = "Invalid photo", Detail = exception.Message });
            }

            var photo = new CartItemPhoto { Id = Guid.NewGuid(), CartItemId = itemId, StorageKey = storageKey, PhotoType = "CUSTOMER_UPLOAD" };
            try
            {
                await carts.AddPhotoAsync(photo, expectedCartVersion, cancellationToken);
            }
            catch
            {
                await photoStorage.DeleteAsync(storageKey, CancellationToken.None);
                throw;
            }

            return Ok(new { photoId = photo.Id });
        }

        [HttpGet("{cartId:guid}/items/{itemId:guid}/photos/{photoId:guid}")]
        public async Task<IActionResult> GetPhoto(Guid cartId, Guid itemId, Guid photoId, CancellationToken cancellationToken)
        {
            var cart = await cartQueries.GetOpenCartAsync(cartId, cancellationToken);
            var photo = cart?.Items.FirstOrDefault(item => item.Item.Id == itemId)?.Photos.FirstOrDefault(photo => photo.Id == photoId);
            if (photo is null)
                return NotFound();
            var stored = await photoStorage.OpenReadAsync(photo.StorageKey, cancellationToken);
            return stored is null ? NotFound() : File(stored.Content, stored.ContentType, enableRangeProcessing: true);
        }

        [HttpDelete("{cartId:guid}/items/{itemId:guid}/photos/{photoId:guid}")]
        public async Task<IActionResult> RemovePhoto(
            Guid cartId,
            Guid itemId,
            Guid photoId,
            [FromQuery, Range(0, int.MaxValue)] int expectedCartVersion,
            CancellationToken cancellationToken)
        {
            var cart = await cartQueries.GetOpenCartAsync(cartId, cancellationToken);
            var photo = cart?.Items.FirstOrDefault(item => item.Item.Id == itemId)?.Photos.FirstOrDefault(photo => photo.Id == photoId);
            if (photo is null)
                return NotFound();

            await carts.RemovePhotoAsync(cartId, itemId, photoId, expectedCartVersion, cancellationToken);
            await photoStorage.DeleteAsync(photo.StorageKey, cancellationToken);
            return NoContent();
        }

        [HttpDelete("{cartId:guid}/items/{itemId:guid}")]
        public async Task<IActionResult> RemoveItem(Guid cartId, Guid itemId, [FromQuery, Range(0, int.MaxValue)] int expectedCartVersion, CancellationToken cancellationToken)
        {
            await carts.RemoveItemAsync(cartId, itemId, expectedCartVersion, cancellationToken);
            return NoContent();
        }

        [HttpDelete("{cartId:guid}/items/{itemId:guid}/services/{serviceId:guid}")]
        public async Task<IActionResult> RemoveService(Guid cartId, Guid itemId, Guid serviceId, [FromQuery, Range(0, int.MaxValue)] int expectedCartVersion, CancellationToken cancellationToken)
        {
            await carts.RemoveServiceAsync(cartId, itemId, serviceId, expectedCartVersion, cancellationToken);
            return NoContent();
        }

        [HttpPut("{cartId:guid}/delivery")]
        public async Task<IActionResult> SetDelivery(Guid cartId, [FromBody] UpdateCartDeliveryRequest request, CancellationToken cancellationToken)
        {
            await carts.SetAddressAndPickupWindowAsync(cartId, request.AddressId, request.PickupWindowStartUtc, request.PickupWindowEndUtc, request.ExpectedCartVersion, cancellationToken);
            return NoContent();
        }
    }

}

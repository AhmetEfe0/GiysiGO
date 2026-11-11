using GiysiGo.API.Errors;
using GiysiGo.Modules.Identity.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace GiysiGo.API.Controllers.Identity
{
    [Route("me")]
    public sealed class MeController(ICustomerSelfService self) : AuthenticatedApiControllerBase
    {
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile(CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            var profile = await self.GetProfileAsync(userId, cancellationToken);
            return profile is null ? Failure(404, "resource_not_found", "Profile was not found.") : Ok(profile);
        }

        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] ProfileUpdateRequest request, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            try
            {
                var profile = await self.UpdateProfileAsync(userId, request.Email ?? string.Empty, cancellationToken);
                return profile is null ? Failure(404, "resource_not_found", "Profile was not found.") : Ok(profile);
            }
            catch (ArgumentException exception) { return ValidationFailure(exception); }
            catch (SqlException exception) when (exception.Number is 2601 or 2627)
            { return Failure(409, "email_conflict", "Email address is already registered."); }
            catch (SqlException exception) when (exception.Number == 51001)
            { return Failure(404, "resource_not_found", "Profile was not found."); }
        }

        [HttpGet("addresses")]
        public async Task<IActionResult> GetAddresses([FromQuery] int page = 1, [FromQuery] int pageSize = 20,
            CancellationToken cancellationToken = default)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            if (page < 1 || pageSize is < 1 or > 100) return ValidationFailure(new ArgumentException("Page must be positive and pageSize must be 1 to 100.", nameof(page)));
            var addresses = await self.GetAddressPageAsync(userId, page, pageSize, cancellationToken);
            return Ok(new AddressPage(addresses.Items.Select(AddressResponse.From).ToArray(), page, pageSize, addresses.TotalCount));
        }

        [HttpGet("addresses/{addressId:guid}")]
        public async Task<IActionResult> GetAddress(Guid addressId, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            if (addressId == Guid.Empty) return ValidationFailure(new ArgumentException("Address ID is required.", nameof(addressId)));
            var address = await self.GetAddressAsync(userId, addressId, cancellationToken);
            return address is null ? Failure(404, "resource_not_found", "Address was not found.") : Ok(AddressResponse.From(address));
        }

        [HttpPost("addresses")]
        public async Task<IActionResult> CreateAddress([FromBody] AddressRequest request, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            try
            {
                var id = await self.CreateAddressAsync(userId, request.ToInput(), cancellationToken);
                return CreatedAtAction(nameof(GetAddress), new { addressId = id }, new { Id = id });
            }
            catch (ArgumentException exception) { return ValidationFailure(exception); }
            catch (SqlException exception) when (exception.Number == 51001)
            { return Failure(404, "resource_not_found", "Profile was not found."); }
        }

        [HttpPut("addresses/{addressId:guid}")]
        public async Task<IActionResult> UpdateAddress(Guid addressId, [FromBody] AddressRequest request, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            try
            {
                var changed = await self.UpdateAddressAsync(userId, addressId, request.ToInput(), cancellationToken);
                return changed ? NoContent() : Failure(404, "resource_not_found", "Address was not found.");
            }
            catch (ArgumentException exception) { return ValidationFailure(exception); }
            catch (SqlException exception) when (exception.Number == 51001)
            { return Failure(404, "resource_not_found", "Address was not found."); }
        }

        [HttpDelete("addresses/{addressId:guid}")]
        public async Task<IActionResult> DeleteAddress(Guid addressId, CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId)) return Failure(401, "authentication_required", "Authentication is required.");
            try
            {
                var deleted = await self.DeleteAddressAsync(userId, addressId, cancellationToken);
                return deleted ? NoContent() : Failure(404, "resource_not_found", "Address was not found.");
            }
            catch (ArgumentException exception) { return ValidationFailure(exception); }
            catch (SqlException exception) when (exception.Number == 51001)
            { return Failure(404, "resource_not_found", "Address was not found."); }
        }

        private ObjectResult ValidationFailure(ArgumentException exception)
        {
            var field = exception.ParamName ?? string.Empty;
            var problem = new ValidationProblemDetails(new Dictionary<string, string[]> { [field] = [exception.Message] })
            {
                Status = 400
            };
            ApiProblem.Complete(HttpContext, problem);
            var response = new ObjectResult(problem) { StatusCode = 400 };
            response.ContentTypes.Add("application/problem+json");
            return response;
        }

        private ObjectResult Failure(int status, string code, string detail)
        {
            var problem = ApiProblem.Create(HttpContext, status, detail: detail);
            problem.Extensions["code"] = code;
            var response = new ObjectResult(problem) { StatusCode = status };
            response.ContentTypes.Add("application/problem+json");
            return response;
        }
    }
}

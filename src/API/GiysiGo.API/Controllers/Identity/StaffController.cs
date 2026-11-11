using GiysiGo.Modules.Identity.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace GiysiGo.API.Controllers.Identity
{
    [TypeFilter(typeof(StaffExceptionFilter))]
    public sealed class StaffController(IStaffManagementService staff) : AuthenticatedApiControllerBase
    {
        [HttpPost("corporates")]
        public async Task<IActionResult> Create(CorporateCreateRequest request, CancellationToken token)
        {
            var id = await staff.CreateCorporateAsync(request.Name, token);
            return StatusCode(201, new { Id = id });
        }

        [HttpPatch("corporates/{id:guid}/active")]
        public async Task<IActionResult> SetActive(Guid id, CorporateActiveRequest request, CancellationToken token)
        {
            await staff.SetCorporateActiveAsync(id, request.IsActive, token);
            return NoContent();
        }

        [HttpGet("corporates/{corporateId:guid}/members")]
        public async Task<IActionResult> Members(Guid corporateId, int page = 1, int pageSize = 20, CancellationToken token = default)
            => Ok(await staff.GetMembersAsync(corporateId, null, page, pageSize, token));

        [HttpGet("corporates/{corporateId:guid}/stores/{storeId:guid}/staff")]
        public async Task<IActionResult> StoreStaff(Guid corporateId, Guid storeId, int page = 1, int pageSize = 20, CancellationToken token = default)
            => Ok(await staff.GetMembersAsync(corporateId, storeId, page, pageSize, token));

        [HttpPut("corporates/{corporateId:guid}/members/{userId:guid}/roles/{roleId:guid}")]
        public async Task<IActionResult> GrantMember(Guid corporateId, Guid userId, Guid roleId, CancellationToken token)
        {
            await staff.ChangeAssignmentAsync(corporateId, null, userId, roleId, true, token);
            return NoContent();
        }

        [HttpDelete("corporates/{corporateId:guid}/members/{userId:guid}/roles/{roleId:guid}")]
        public async Task<IActionResult> RevokeMember(Guid corporateId, Guid userId, Guid roleId, CancellationToken token)
        {
            await staff.ChangeAssignmentAsync(corporateId, null, userId, roleId, false, token);
            return NoContent();
        }

        [HttpPut("corporates/{corporateId:guid}/stores/{storeId:guid}/staff/{userId:guid}/roles/{roleId:guid}")]
        public async Task<IActionResult> GrantStaff(Guid corporateId, Guid storeId, Guid userId, Guid roleId, CancellationToken token)
        {
            await staff.ChangeAssignmentAsync(corporateId, storeId, userId, roleId, true, token);
            return NoContent();
        }

        [HttpDelete("corporates/{corporateId:guid}/stores/{storeId:guid}/staff/{userId:guid}/roles/{roleId:guid}")]
        public async Task<IActionResult> RevokeStaff(Guid corporateId, Guid storeId, Guid userId, Guid roleId, CancellationToken token)
        {
            await staff.ChangeAssignmentAsync(corporateId, storeId, userId, roleId, false, token);
            return NoContent();
        }

        [HttpGet("me/access")]
        public async Task<IActionResult> Access(CancellationToken token)
            => Ok(await staff.GetMyAccessAsync(token));
    }
}

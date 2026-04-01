using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using BlazorShared.Authorization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;

namespace Microsoft.eShopWeb.Web.Controllers;

[Route("[controller]")]
[ApiController]
public class UserController : ControllerBase
{
    private readonly ITokenClaimsService _tokenClaimsService;

    public UserController(ITokenClaimsService tokenClaimsService)
    {
        _tokenClaimsService = tokenClaimsService;
    }

    [HttpGet]
    [Authorize]
    [AllowAnonymous]
    public async Task<IActionResult> GetCurrentUser()
    {
        var identity = User.Identity;
        if (identity?.IsAuthenticated != true)
        {
            return Ok(UserInfo.Anonymous);
        }

        return Ok(await CreateUserInfo(User));
    }

    private async Task<UserInfo> CreateUserInfo(ClaimsPrincipal claimsPrincipal)
    {
        ArgumentNullException.ThrowIfNull(claimsPrincipal);

        var principal = claimsPrincipal;
        var identity = principal.Identity;
        if (identity?.IsAuthenticated != true)
        {
            return UserInfo.Anonymous;
        }

        var userInfo = new UserInfo
        {
            IsAuthenticated = true
        };

        if (identity is ClaimsIdentity claimsIdentity)
        {
            userInfo.NameClaimType = claimsIdentity.NameClaimType;
            userInfo.RoleClaimType = claimsIdentity.RoleClaimType;
        }
        else
        {
            userInfo.NameClaimType = "name";
            userInfo.RoleClaimType = "role";
        }

        var allClaims = principal.Claims.ToList();
        if (allClaims.Count > 0)
        {
            var claims = new List<ClaimValue>();
            var nameClaims = principal.FindAll(userInfo.NameClaimType).ToList();
            foreach (var claim in nameClaims)
            {
                claims.Add(new ClaimValue(userInfo.NameClaimType, claim.Value));
            }

            foreach (var claim in allClaims.Except(nameClaims))
            {
                claims.Add(new ClaimValue(claim.Type, claim.Value));
            }

            userInfo.Claims = claims;
        }

        var token = await _tokenClaimsService.GetTokenAsync(identity.Name ?? string.Empty);
        userInfo.Token = token;

        return userInfo;
    }
}

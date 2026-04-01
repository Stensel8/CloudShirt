using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb.ApplicationCore.Constants;

namespace Microsoft.eShopWeb.Infrastructure.Identity;

public class AppIdentityDbContextSeed
{
    public static async Task SeedAsync(AppIdentityDbContext identityDbContext, UserManager<ApplicationUser> userManager, RoleManager<IdentityRole> roleManager)
    {

        if (identityDbContext.Database.IsRelational())
        {
            // Transitional path while SQL Server migrations are still present.
            await identityDbContext.Database.EnsureCreatedAsync();
        }

        if (!await roleManager.RoleExistsAsync(BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS))
        {
            await roleManager.CreateAsync(new IdentityRole(BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS));
        }

        const string defaultUserName = "demouser@microsoft.com";
        if (await userManager.FindByNameAsync(defaultUserName) is null)
        {
            var defaultUser = new ApplicationUser { UserName = defaultUserName, Email = defaultUserName };
            await userManager.CreateAsync(defaultUser, AuthorizationConstants.DEFAULT_PASSWORD);
        }

        string adminUserName = "admin@microsoft.com";
        var adminUser = await userManager.FindByNameAsync(adminUserName);
        if (adminUser is null)
        {
            adminUser = new ApplicationUser { UserName = adminUserName, Email = adminUserName };
            await userManager.CreateAsync(adminUser, AuthorizationConstants.DEFAULT_PASSWORD);
            adminUser = await userManager.FindByNameAsync(adminUserName);
        }

        if (adminUser is null)
        {
            return;
        }

        if (await userManager.IsInRoleAsync(adminUser, BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS))
        {
            return;
        }

        await userManager.AddToRoleAsync(adminUser, BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS);
    }
}

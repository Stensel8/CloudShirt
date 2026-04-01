using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb.Infrastructure.Data;
using Microsoft.eShopWeb.Infrastructure.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Microsoft.eShopWeb.Infrastructure;

public static class Dependencies
{
    public static void ConfigureServices(IConfiguration configuration, IServiceCollection services)
    {
        var useOnlyInMemoryDatabase = bool.TryParse(configuration["UseOnlyInMemoryDatabase"], out var useInMemory)
            && useInMemory;

        var databaseProvider = configuration["DatabaseProvider"]?.Trim().ToLowerInvariant() ?? "postgres";
        var catalogConnectionString = configuration.GetConnectionString("CatalogConnection");
        var identityConnectionString = configuration.GetConnectionString("IdentityConnection");

        if (useOnlyInMemoryDatabase)
        {
            services.AddDbContext<CatalogContext>(c =>
               c.UseInMemoryDatabase("Catalog"));

            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseInMemoryDatabase("Identity"));
        }
        else if (databaseProvider == "sqlite")
        {
            services.AddDbContext<CatalogContext>(c =>
                c.UseSqlite(catalogConnectionString));

            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseSqlite(identityConnectionString));
        }
        else
        {
            // PostgreSQL blijft de container-variant voor Docker en cloud-demonstraties.
            services.AddDbContext<CatalogContext>(c =>
                c.UseNpgsql(catalogConnectionString));

            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseNpgsql(identityConnectionString));
        }
    }
}

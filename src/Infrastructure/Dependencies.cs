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

        if (useOnlyInMemoryDatabase)
        {
            services.AddDbContext<CatalogContext>(c =>
               c.UseInMemoryDatabase("Catalog"));

            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseInMemoryDatabase("Identity"));
        }
        else
        {
            var catalogConnectionString = configuration.GetConnectionString("CatalogConnection");
            var identityConnectionString = configuration.GetConnectionString("IdentityConnection");

            // PostgreSQL is the default relational runtime for Docker/Swarm/AWS readiness.
            // Keep the provider key to support future extension without changing config shape.
            _ = databaseProvider;

            services.AddDbContext<CatalogContext>(c =>
                c.UseNpgsql(catalogConnectionString));

            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseNpgsql(identityConnectionString));
        }
    }
}

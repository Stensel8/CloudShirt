using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using Microsoft.Extensions.Logging;

namespace Microsoft.eShopWeb.Infrastructure.Data;

public class CatalogContextSeed
{
    public static async Task SeedAsync(CatalogContext catalogContext,
        ILogger logger,
        int retry = 0)
    {
        var retryForAvailability = retry;
        try
        {
            if (catalogContext.Database.IsRelational())
            {
                // Transitional path while SQL Server migrations are still present.
                await catalogContext.Database.EnsureCreatedAsync();
            }

            if (!await catalogContext.CatalogBrands.AnyAsync())
            {
                await catalogContext.CatalogBrands.AddRangeAsync(
                    GetPreconfiguredCatalogBrands());

                await catalogContext.SaveChangesAsync();
            }

            if (!await catalogContext.CatalogTypes.AnyAsync())
            {
                await catalogContext.CatalogTypes.AddRangeAsync(
                    GetPreconfiguredCatalogTypes());

                await catalogContext.SaveChangesAsync();
            }

            if (!await catalogContext.CatalogItems.AnyAsync())
            {
                await catalogContext.CatalogItems.AddRangeAsync(
                    GetPreconfiguredItems());

                await catalogContext.SaveChangesAsync();
            }
            else
            {
                var existingProductImageNumbers = await catalogContext.CatalogItems
                    .Select(ci => ci.PictureUri)
                    .Where(uri => !string.IsNullOrEmpty(uri))
                    .Select(uri => GetProductImageNumber(uri!))
                    .Where(number => number.HasValue)
                    .Select(number => number!.Value)
                    .ToListAsync();

                var missingItems = GetPreconfiguredItems()
                    .Where(item => !existingProductImageNumbers.Contains(GetProductImageNumber(item.PictureUri) ?? -1))
                    .ToList();

                if (missingItems.Count > 0)
                {
                    await catalogContext.CatalogItems.AddRangeAsync(missingItems);
                    await catalogContext.SaveChangesAsync();
                }
            }
        }
        catch (Exception ex)
        {
            if (retryForAvailability >= 10) throw;

            retryForAvailability++;

            logger.LogError(ex, "Error while seeding catalog context");
            await SeedAsync(catalogContext, logger, retryForAvailability);
            throw;
        }
    }

    static IEnumerable<CatalogBrand> GetPreconfiguredCatalogBrands()
    {
        return new List<CatalogBrand>
            {
                new("Azure"),
                new(".NET"),
                new("Visual Studio"),
                new("SQL Server"),
                new("Other")
            };
    }

    static IEnumerable<CatalogType> GetPreconfiguredCatalogTypes()
    {
        return new List<CatalogType>
            {
                new("Mug"),
                new("T-Shirt"),
                new("Sheet")
            };
    }

    static IEnumerable<CatalogItem> GetPreconfiguredItems()
    {
        return new List<CatalogItem>
            {
                new(2,2, ".NET Bot Black Sweatshirt", ".NET Bot Black Sweatshirt", 19.5M,  "http://catalogbaseurltobereplaced/images/products/1.avif"),
                new(1,2, ".NET Black & White Mug", ".NET Black & White Mug", 8.50M, "http://catalogbaseurltobereplaced/images/products/2.avif"),
                new(2,5, "Prism White T-Shirt", "Prism White T-Shirt", 12,  "http://catalogbaseurltobereplaced/images/products/3.avif"),
                new(2,2, ".NET Foundation Sweatshirt", ".NET Foundation Sweatshirt", 12, "http://catalogbaseurltobereplaced/images/products/4.avif"),
                new(3,5, "Roslyn Red Sheet", "Roslyn Red Sheet", 8.5M, "http://catalogbaseurltobereplaced/images/products/5.avif"),
                new(2,2, ".NET Blue Sweatshirt", ".NET Blue Sweatshirt", 12, "http://catalogbaseurltobereplaced/images/products/6.avif"),
                new(2,5, "Roslyn Red T-Shirt", "Roslyn Red T-Shirt",  12, "http://catalogbaseurltobereplaced/images/products/7.avif"),
                new(2,5, "Kudu Purple Sweatshirt", "Kudu Purple Sweatshirt", 8.5M, "http://catalogbaseurltobereplaced/images/products/8.avif"),
                new(1,5, "Cup<T> White Mug", "Cup<T> White Mug", 12, "http://catalogbaseurltobereplaced/images/products/9.avif"),
                new(3,2, ".NET Foundation Sheet", ".NET Foundation Sheet", 12, "http://catalogbaseurltobereplaced/images/products/10.avif"),
                new(3,2, "Cup<T> Sheet", "Cup<T> Sheet", 8.5M, "http://catalogbaseurltobereplaced/images/products/11.avif"),
                new(2,5, "Prism White TShirt", "Prism White TShirt", 12, "http://catalogbaseurltobereplaced/images/products/12.avif"),

                new(2,1, "Dad, What Are Clouds Made Of? T-Shirt", "Dad, What Are Clouds Made Of? T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/13.avif"),
                new(2,1, "Azure Certified T-Shirt", "Azure Certified T-Shirt", 17.00M, "http://catalogbaseurltobereplaced/images/products/14.avif"),
                new(2,1, "Microsoft Teams T-Shirt", "Microsoft Teams T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/15.avif"),
                new(2,1, "Git Going! T-Shirt", "Git Going! T-Shirt", 18.00M, "http://catalogbaseurltobereplaced/images/products/16.avif"),
                new(2,1, "Microsoft Teams Logo T-Shirt", "Microsoft Teams Logo T-Shirt", 19.00M, "http://catalogbaseurltobereplaced/images/products/17.avif"),
                new(2,1, "Cloud Architect Hourly Rate T-Shirt", "Cloud Architect Hourly Rate T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/18.avif"),

                new(2,4, "SQL Server Database Administrator T-Shirt", "SQL Server Database Administrator T-Shirt", 18.00M, "http://catalogbaseurltobereplaced/images/products/19.avif"),
                new(2,4, "SQL for Beginners T-Shirt", "SQL for Beginners T-Shirt", 18.00M, "http://catalogbaseurltobereplaced/images/products/20.avif"),
                new(2,4, "Huge Fan of Databases T-Shirt", "Huge Fan of Databases T-Shirt", 19.50M, "http://catalogbaseurltobereplaced/images/products/21.avif"),
                new(2,4, "SQL Server DBA T-Shirt", "SQL Server DBA T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/22.avif"),
                new(2,5, "i <? php T-Shirt", "i <? php T-Shirt", 19.50M, "http://catalogbaseurltobereplaced/images/products/23.avif"),
                new(2,4, "Keep Calm I'm a DBA T-Shirt", "Keep Calm I'm a DBA T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/24.avif"),

                new(2,1, "Microsoft Teams Word Art T-Shirt", "Microsoft Teams Word Art T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/25.avif"),
                new(2,1, "There Is No Cloud T-Shirt", "There Is No Cloud T-Shirt", 18.00M, "http://catalogbaseurltobereplaced/images/products/26.avif"),
                new(2,1, "Azure Cloud Connect T-Shirt", "Azure Cloud Connect T-Shirt", 18.00M, "http://catalogbaseurltobereplaced/images/products/27.avif"),
                new(2,1, "Microsoft Office Logo T-Shirt", "Microsoft Office Logo T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/28.avif"),

                new(2,4, "SQL QIC T-Shirt", "SQL QIC T-Shirt", 20.00M, "http://catalogbaseurltobereplaced/images/products/29.avif"),
                new(2,4, "Database Schema T-Shirt", "Database Schema T-Shirt", 18.00M, "http://catalogbaseurltobereplaced/images/products/30.avif"),
                new(2,4, "SELECT COUNT(*) T-Shirt", "SELECT COUNT(*) T-Shirt", 19.00M, "http://catalogbaseurltobereplaced/images/products/31.avif"),

                new(2,3, "VS Code Logo T-Shirt", "VS Code Logo T-Shirt", 19.50M, "http://catalogbaseurltobereplaced/images/products/32.avif"),
                new(2,3, "Semicolon Programmer T-Shirt", "Semicolon Programmer T-Shirt", 20.00M, "http://catalogbaseurltobereplaced/images/products/33.avif"),
                new(2,3, "Visual Studio Logo T-Shirt", "Visual Studio Logo T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/34.avif"),
                new(1,3, "Visual Studio Logo Mug", "Visual Studio Logo Mug", 10.50M, "http://catalogbaseurltobereplaced/images/products/35.avif"),
                new(2,5, "Design Is Thinking Made Visual T-Shirt", "Design Is Thinking Made Visual T-Shirt", 18.50M, "http://catalogbaseurltobereplaced/images/products/37.avif")
            };
    }

    static int? GetProductImageNumber(string uri)
    {
        const string marker = "/images/products/";
        var markerIndex = uri.LastIndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var fileNameStart = markerIndex + marker.Length;
        var fileName = uri[fileNameStart..];
        var queryIndex = fileName.IndexOf('?');
        if (queryIndex >= 0) fileName = fileName[..queryIndex];

        var extensionIndex = fileName.LastIndexOf('.');
        if (extensionIndex > 0) fileName = fileName[..extensionIndex];

        return int.TryParse(fileName, out var imageNumber) ? imageNumber : null;
    }
}

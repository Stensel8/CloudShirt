using Microsoft.eShopWeb.ApplicationCore.Interfaces;

namespace Microsoft.eShopWeb.ApplicationCore.Services;

public class UriComposer : IUriComposer
{
    private readonly CatalogSettings _catalogSettings;

    public UriComposer(CatalogSettings catalogSettings) => _catalogSettings = catalogSettings;

    public string ComposePicUri(string uriTemplate)
    {
        var composedUri = uriTemplate.Replace("http://catalogbaseurltobereplaced", _catalogSettings.CatalogBaseUrl);

        // Backward compatibility for old seeded data that referenced png assets.
        if (composedUri.Contains("/images/products/", StringComparison.OrdinalIgnoreCase) &&
            composedUri.EndsWith(".png", StringComparison.OrdinalIgnoreCase))
        {
            composedUri = composedUri[..^4] + ".avif";
        }

        return composedUri;
    }
}

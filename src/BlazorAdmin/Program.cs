using System;
using System.Net.Http;
using System.Threading.Tasks;
using BlazorAdmin;
using BlazorAdmin.Services;
using Blazored.LocalStorage;
using BlazorShared;
using BlazorShared.Models;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#admin");
builder.RootComponents.Add<HeadOutlet>("head::after");

var configSection = builder.Configuration.GetRequiredSection(BaseUrlConfiguration.CONFIG_NAME);
builder.Services.Configure<BaseUrlConfiguration>(configSection);

var baseUrlConfig = configSection.Get<BaseUrlConfiguration>() ?? new BaseUrlConfiguration();
var resolvedApiBase = ResolveApiBase(baseUrlConfig.ApiBase, builder.HostEnvironment.BaseAddress);
builder.Services.Configure<BaseUrlConfiguration>(options =>
{
    options.ApiBase = resolvedApiBase;
    options.WebBase = baseUrlConfig.WebBase;
});

builder.Services.AddScoped(sp => new HttpClient() { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

builder.Services.AddScoped<ToastService>();
builder.Services.AddScoped<HttpService>();

builder.Services.AddBlazoredLocalStorage();

builder.Services.AddAuthorizationCore();
builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthStateProvider>();
builder.Services.AddScoped(sp => (CustomAuthStateProvider)sp.GetRequiredService<AuthenticationStateProvider>());

builder.Services.AddBlazorServices();

builder.Logging.AddConfiguration(builder.Configuration.GetRequiredSection("Logging"));

await ClearLocalStorageCache(builder.Services);

await builder.Build().RunAsync();

static string ResolveApiBase(string configuredApiBase, string hostBaseAddress)
{
    if (!Uri.TryCreate(hostBaseAddress, UriKind.Absolute, out var hostUri))
    {
        return configuredApiBase;
    }

    if (string.Equals(hostUri.Host, "localhost", StringComparison.OrdinalIgnoreCase))
    {
        if (hostUri.Scheme == Uri.UriSchemeHttp && hostUri.Port == 5106)
            return "http://localhost:5200/api/";

        if (hostUri.Scheme == Uri.UriSchemeHttps && hostUri.Port == 5001)
            return "https://localhost:5099/api/";

        return configuredApiBase;
    }

    // Productie: API zit op dezelfde host als de browser (ALB, EC2, etc.)
    return $"{hostUri.Scheme}://{hostUri.Authority}/api/";
}

static async Task ClearLocalStorageCache(IServiceCollection services)
{
    var sp = services.BuildServiceProvider();
    var localStorageService = sp.GetRequiredService<ILocalStorageService>();

    await localStorageService.RemoveItemAsync(typeof(CatalogBrand).Name);
    await localStorageService.RemoveItemAsync(typeof(CatalogType).Name);
}

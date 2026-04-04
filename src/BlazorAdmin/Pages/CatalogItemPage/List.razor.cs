using System.Collections.Generic;
using System.Threading.Tasks;
using BlazorAdmin.Helpers;
using BlazorShared.Interfaces;
using BlazorShared.Models;

namespace BlazorAdmin.Pages.CatalogItemPage;

public partial class List : BlazorComponent
{
    [Microsoft.AspNetCore.Components.Inject]
    public ICatalogItemService CatalogItemService { get; set; } = null!;

    [Microsoft.AspNetCore.Components.Inject]
    public ICatalogLookupDataService<CatalogBrand> CatalogBrandService { get; set; } = null!;

    [Microsoft.AspNetCore.Components.Inject]
    public ICatalogLookupDataService<CatalogType> CatalogTypeService { get; set; } = null!;

    private List<CatalogItem> catalogItems = new List<CatalogItem>();
    private List<CatalogType> catalogTypes = new List<CatalogType>();
    private List<CatalogBrand> catalogBrands = new List<CatalogBrand>();

    private Edit EditComponent { get; set; } = null!;
    private Delete DeleteComponent { get; set; } = null!;
    private Details DetailsComponent { get; set; } = null!;
    private Create CreateComponent { get; set; } = null!;

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            catalogItems = await CatalogItemService.List();
            catalogTypes = await CatalogTypeService.List();
            catalogBrands = await CatalogBrandService.List();

            CallRequestRefresh();
        }

        await base.OnAfterRenderAsync(firstRender);
    }

    private async void DetailsClick(int id)
    {
        await DetailsComponent.Open(id);
    }

    private async Task CreateClick()
    {
        await CreateComponent.Open();
    }

    private async Task EditClick(int id)
    {
        await EditComponent.Open(id);
    }

    private async Task DeleteClick(int id)
    {
        await DeleteComponent.Open(id);
    }

    private async Task ReloadCatalogItems()
    {
        catalogItems = await CatalogItemService.List();
        StateHasChanged();
    }
}

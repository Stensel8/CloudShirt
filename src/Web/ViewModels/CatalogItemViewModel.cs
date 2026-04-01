namespace Microsoft.eShopWeb.Web.ViewModels;

public class CatalogItemViewModel
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PictureUri { get; set; } = string.Empty;
    public decimal Price { get; set; }
}

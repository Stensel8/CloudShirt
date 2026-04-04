namespace Microsoft.eShopWeb.PublicApi.CatalogItemEndpoints;

public class CatalogItemDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string PictureUri { get; set; } = string.Empty;
    public int CatalogTypeId { get; set; }
    public int CatalogBrandId { get; set; }
}

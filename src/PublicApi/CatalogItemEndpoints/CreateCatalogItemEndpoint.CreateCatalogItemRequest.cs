namespace Microsoft.eShopWeb.PublicApi.CatalogItemEndpoints;

public class CreateCatalogItemRequest : BaseRequest
{
    public int CatalogBrandId { get; set; }
    public int CatalogTypeId { get; set; }
    public string Description { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string PictureUri { get; set; } = string.Empty;
    public string PictureBase64 { get; set; } = string.Empty;
    public string PictureName { get; set; } = string.Empty;
    public decimal Price { get; set; }
}

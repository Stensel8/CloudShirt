using System.ComponentModel.DataAnnotations;

namespace Microsoft.eShopWeb.PublicApi.CatalogItemEndpoints;

public class UpdateCatalogItemRequest : BaseRequest
{
    [Range(1, 10000)]
    public int Id { get; set; }
    [Range(1, 10000)]
    public int CatalogBrandId { get; set; }
    [Range(1, 10000)]
    public int CatalogTypeId { get; set; }
    [Required]
    public string Description { get; set; } = string.Empty;
    [Required]
    public string Name { get; set; } = string.Empty;
    public string PictureBase64 { get; set; } = string.Empty;
    public string PictureUri { get; set; } = string.Empty;
    public string PictureName { get; set; } = string.Empty;
    [Range(0.01, 10000)]
    public decimal Price { get; set; }
}

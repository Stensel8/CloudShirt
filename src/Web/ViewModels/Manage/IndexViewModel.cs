using System.ComponentModel.DataAnnotations;

namespace Microsoft.eShopWeb.Web.ViewModels.Manage;

public class IndexViewModel
{
    public string? Username { get; set; }

    public bool IsEmailConfirmed { get; set; }

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Phone]
    [Display(Name = "Phone number")]
    public string PhoneNumber { get; set; } = string.Empty;

    public string? StatusMessage { get; set; }
}

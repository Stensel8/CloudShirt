namespace Microsoft.eShopWeb.PublicApi.AuthEndpoints;

public class AuthenticateRequest : BaseRequest
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

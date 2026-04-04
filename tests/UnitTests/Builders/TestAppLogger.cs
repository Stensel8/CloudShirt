using Microsoft.eShopWeb.ApplicationCore.Interfaces;

namespace Microsoft.eShopWeb.UnitTests.Builders;

public class TestAppLogger<T> : IAppLogger<T>
{
    public void LogWarning(string message, params object[] args)
    {
    }

    public void LogInformation(string message, params object[] args)
    {
    }
}

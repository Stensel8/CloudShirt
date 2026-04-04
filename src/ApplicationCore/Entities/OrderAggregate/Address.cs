namespace Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;

public class Address // ValueObject
{
    public string Street { get; private set; } = string.Empty;

    public string City { get; private set; } = string.Empty;

    public string State { get; private set; } = string.Empty;

    public string Country { get; private set; } = string.Empty;

    public string ZipCode { get; private set; } = string.Empty;

    private Address() { }

    public Address(string street, string city, string state, string country, string zipcode)
    {
        Street = street;
        City = city;
        State = state;
        Country = country;
        ZipCode = zipcode;
    }
}

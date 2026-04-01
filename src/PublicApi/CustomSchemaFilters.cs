using Microsoft.OpenApi;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Microsoft.eShopWeb.PublicApi;

public class CustomSchemaFilters : ISchemaFilter
{
    public void Apply(IOpenApiSchema schema, SchemaFilterContext context)
    {
        var excludeProperties = new[] { "CorrelationId" };

        foreach (var prop in excludeProperties)
            if (schema.Properties.ContainsKey(prop))
                schema.Properties.Remove(prop);
    }
}

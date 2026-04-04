using System.Globalization;
using Microsoft.AspNetCore.Components.Forms;

namespace BlazorAdmin.Shared;

/// <summary>
/// This is needed until 5.0 ships with native support
/// https://www.pragimtech.com/blog/blazor/inputselect-does-not-support-system.int32/
/// </summary>
/// <typeparam name="TValue"></typeparam>
public class CustomInputSelect<TValue> : InputSelect<TValue>
{
    protected override bool TryParseValueFromString(string? value, out TValue result,
        out string validationErrorMessage)
    {
        if (BindConverter.TryConvertTo<TValue>(value, CultureInfo.CurrentCulture, out var parsedValue))
        {
            result = parsedValue!;
            validationErrorMessage = string.Empty;
            return true;
        }

        result = default!;
        validationErrorMessage = $"The selected value {value} is not valid.";
        return false;
    }
}

using System.Globalization;
using System.Collections.Generic;

namespace Company.Function
{
    // demo code, usually want to pull these from key vault or config etc.
    internal static class Constants
    {
        internal static string audience = "api://apiapp01"; // Get this value from the expose an api, audience uri section example https://appname.tenantname.onmicrosoft.com
        internal static string clientID = "c85f5c98-1c82-45e1-9746-216c097c45cc"; // this is the client id, also known as AppID. This is not the ObjectID
        internal static string tenant = "ashleyhollisoutlook.onmicrosoft.com"; // this is your tenant name
        internal static string tenantid = "c2d723a2-474e-44d2-a37c-9b4e9cb823d4"; // this is your tenant id (GUID)

        // rest of the values below can be left as is in most circumstances
        internal static string aadInstance = "https://login.microsoftonline.com/{0}/v2.0";
        internal static string authority = string.Format(CultureInfo.InvariantCulture, aadInstance, tenant);
        internal static List<string> validIssuers = new List<string>()
            {
                $"https://login.microsoftonline.com/{tenant}/",
                $"https://login.microsoftonline.com/{tenant}/v2.0",
                $"https://login.windows.net/{tenant}/",
                $"https://login.microsoft.com/{tenant}/",
                $"https://sts.windows.net/{tenantid}/"
            };
    }
}
using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

using System.Collections.Generic;
using System.Globalization;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.Identity.Client;
using Microsoft.IdentityModel.Tokens;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using System.Linq;
using System.Security.Claims;
using System.Net.Http;
using System.Reflection.Metadata;

namespace Company.Function
{
  public static class BootLoader
  {
    [FunctionName("BootLoader")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post",
            Route = "{requestedRoute}")] HttpRequest req,
        string requestedRoute,
        ILogger log)
    {
      log.LogInformation("C# HTTP trigger function processed a request.");
      requestedRoute = requestedRoute.ToLower();
      switch (requestedRoute)
      {
        case "anonymous":
          return Anonymous(req, log);
        case "authenticated":
          return await Authenticated(req, log);
        default:
          break;
      }

      return new BadRequestObjectResult(new
      {
        status = "failure",
        message = "Unknown requested route."
      });
    }

    private static IActionResult Anonymous(HttpRequest req, ILogger log)
    {
      return new OkObjectResult(new
      {
        status = "success",
        type = "anonymous"
      });
    }

    private static async Task<string> GetGraphAccessToken()
    {
      var clientID = Constants.clientID;
      var authority = Constants.authority;

      var clientSecret = Environment.GetEnvironmentVariable("ClientSecret");

      // Create the confidential client application
      var app = ConfidentialClientApplicationBuilder.Create(clientID)
          .WithClientSecret(clientSecret)
          .WithAuthority(new Uri(authority))
          .Build();

      // Use the .default scope
      var scopes = new string[] { "https://graph.microsoft.com/.default" };

      // Acquire the token
      try
      {
        var result = await app.AcquireTokenForClient(scopes).ExecuteAsync();
        return result.AccessToken;
      }
      catch (System.Exception ex)
      {
        throw ex;
      }
    }

    private static async Task<string> GetAppNameFromGraphAPI(string appid)
    {
      string graphToken = await GetGraphAccessToken();
      string url = $"https://graph.microsoft.com/v1.0/applications?$filter=appId eq '{appid}'";

      using (var client = new HttpClient())
      {
        client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", graphToken);
        HttpResponseMessage response = await client.GetAsync(url);

        if (response.IsSuccessStatusCode)
        {
          string content = await response.Content.ReadAsStringAsync();
          var applicationDetails = JsonConvert.DeserializeObject<dynamic>(content);
          return applicationDetails.value[0].displayName;
        }
        else
        {
          return "Unknown App";
        }
      }
    }

    private static async Task<IActionResult> Authenticated(HttpRequest req, ILogger log)
    {
      var accessToken = GetAccessToken(req);
      var claimsPrincipal = await ValidateAccessToken(accessToken, log);

      if (claimsPrincipal != null)
      {
        var identityName = claimsPrincipal.Identity.Name;

        if (string.IsNullOrEmpty(identityName))
        {
          // Scenario: Client credential flow.
          var appidClaim = claimsPrincipal.Claims.FirstOrDefault(c => c.Type == "appid");
          if (appidClaim != null)
          {

            var appName = await GetAppNameFromGraphAPI(appidClaim.Value);
            return new OkObjectResult(new
            {
              status = "success",
              type = "clientCredentialFlow",
              appid = appidClaim.Value,
              appName = appName // This is the name of the app registration
            });
          }
          else
          {
            return new BadRequestObjectResult(new
            {
              status = "failure",
              message = "AppID claim not found."
            });
          }
        }

        // Scenario: User Identity available.
        return new OkObjectResult(new
        {
          status = "success",
          type = "user",
          identity = identityName
        });
      }

      // Scenario: Token validation fails.
      var unauthorizedResponse = new ObjectResult(new
      {
        status = "unauthorized",
        message = "Token validation failed."
      })
      {
        StatusCode = (int)System.Net.HttpStatusCode.Unauthorized
      };
      return unauthorizedResponse;
    }

    private static string GetAccessToken(HttpRequest req)
    {
      var authorizationHeader = req.Headers?["Authorization"];
      string[] parts = authorizationHeader?.ToString().Split(null) ?? new string[0];
      if (parts.Length == 2 && parts[0].Equals("Bearer"))
        return parts[1];
      return null;
    }

    private static async Task<ClaimsPrincipal> ValidateAccessToken(string accessToken, ILogger log)
    {
      var audience = Constants.audience;
      var clientID = Constants.clientID;
      var tenant = Constants.tenant;
      var tenantid = Constants.tenantid;
      var aadInstance = Constants.aadInstance;
      var authority = Constants.authority;
      var validIssuers = Constants.validIssuers;

      // Debugging purposes only, set this to false for production
      Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true;

      ConfigurationManager<OpenIdConnectConfiguration> configManager =
          new ConfigurationManager<OpenIdConnectConfiguration>(
              $"{authority}/.well-known/openid-configuration",
              new OpenIdConnectConfigurationRetriever());

      OpenIdConnectConfiguration config = null;
      config = await configManager.GetConfigurationAsync();

      ISecurityTokenValidator tokenValidator = new JwtSecurityTokenHandler();

      // Initialize the token validation parameters
      TokenValidationParameters validationParameters = new TokenValidationParameters
      {
        // App Id URI and AppId of this service application are both valid audiences.
        ValidAudiences = new[] { audience, clientID },

        // Support Azure AD V1 and V2 endpoints.
        ValidIssuers = validIssuers,
        IssuerSigningKeys = config.SigningKeys
      };

      try
      {
        SecurityToken securityToken;
        var claimsPrincipal = tokenValidator.ValidateToken(accessToken, validationParameters, out securityToken);
        return claimsPrincipal;
      }
      catch (Exception ex)
      {
        log.LogError(ex.ToString());
      }
      return null;
    }
  }
}


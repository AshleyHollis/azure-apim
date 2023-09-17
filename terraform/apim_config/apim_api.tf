resource "azurerm_api_management_api" "auth-tester" {
  name                  = "auth-tester"
  resource_group_name   = local.resource_group_name
  api_management_name   = local.api_management_name
  revision              = "1"
  display_name          = "auth-tester"
  path                  = "auth-tester"
  protocols             = ["https"]
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "auth-tester-anonymous" {
  operation_id        = "auth-tester-anonymous"
  api_name            = azurerm_api_management_api.auth-tester.name
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  display_name        = "anonymous"
  method              = "GET"
  url_template        = "/anonymous"
}

resource "azurerm_api_management_api_operation" "auth-tester-authenticated" {
  operation_id        = "auth-tester-authenticated"
  api_name            = azurerm_api_management_api.auth-tester.name
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  display_name        = "authenticated"
  method              = "GET"
  url_template        = "/authenticated"
}

resource "azurerm_api_management_api_operation" "auth-tester-not-found" {
  operation_id        = "auth-tester-not-found"
  api_name            = azurerm_api_management_api.auth-tester.name
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  display_name        = "not-found"
  method              = "GET"
  url_template        = "/not-found"
}
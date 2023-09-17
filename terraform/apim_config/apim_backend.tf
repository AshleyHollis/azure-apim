resource "azurerm_api_management_backend" "auth-tester" {
  name                = "auth-tester"
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  protocol            = "http"
  url                 = "https://ahapiapp01.azurewebsites.net"
  resource_id         = "/subscriptions/28aefbe7-e2af-4b4a-9ce1-92d6672c31bd/resourceGroups/apim/providers/Microsoft.Web/sites/ahapiapp01"
}
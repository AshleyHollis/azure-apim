resource "azurerm_api_management" "main" {
  name                = "ahapimpoc"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "Ashley Hollis"
  publisher_email     = "me@ashleyhollis.com"

  sku_name = "Developer_1"
}
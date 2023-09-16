resource "azurerm_service_plan" "main" {
  name                = "ahfnapps"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_storage_account" "fnapps" {
  name                     = "ahfnapps"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_function_app" "apiapp01" {
  name                = "ahapiapp01"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.fnapps.name
  storage_account_access_key = azurerm_storage_account.fnapps.primary_access_key

  service_plan_id = azurerm_service_plan.fnapps.id

  site_config {}
}
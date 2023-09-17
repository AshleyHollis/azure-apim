provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id = var.apiappadtenant
}

resource "azurerm_resource_group" "main" {
  name     = "apim"
  location = "australiaeast"
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "apim"
  location = "australiaeast"
}
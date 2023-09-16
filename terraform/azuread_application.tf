data "azuread_client_config" "current" {}

resource "azuread_application" "apiapp01" {
  display_name     = "apiapp01"
  identifier_uris  = ["api://apiapp01"]
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_application" "clientapp01" {
  display_name     = "clientapp01"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_application" "clientapp02" {
  display_name     = "clientapp02"
  owners           = [data.azuread_client_config.current.object_id]
}
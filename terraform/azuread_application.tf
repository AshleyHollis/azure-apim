data "azuread_client_config" "current" {}

resource "azuread_application" "apiapp01" {
  display_name     = "apiapp01"
  identifier_uris  = ["api://apiapp01"]
  owners           = [data.azuread_client_config.current.object_id]

  api {
    mapped_claims_enabled = false
    requested_access_token_version = 1
    
    known_client_applications = []
    
    oauth2_permission_scope {
      admin_consent_description = "user_impersonation"
      admin_consent_display_name = "user_impersonation"
      enabled = true
      id = "4fb831e9-51a3-401c-a2e0-6a3447745131"
      type = "User"
      user_consent_description = "user_impersonation"
      user_consent_display_name = "user_impersonation"
      value = "user_impersonation"
    }
  }

  required_resource_access {  
    resource_app_id = "00000003-0000-0000-c000-000000000000"  
    resource_access {  
      id = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"  
      type = "Role"
    }
  }

  web {  
    homepage_url = "http://localhost:7071"
    logout_url = "http://localhost:7071"
    redirect_uris = [ "http://localhost:7071/" ]
    implicit_grant {  
      access_token_issuance_enabled = true  
      id_token_issuance_enabled = true
    }
  }
}

resource "azuread_application" "clientapp01" {
  display_name     = "clientapp01"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_application" "clientapp02" {
  display_name     = "clientapp02"
  owners           = [data.azuread_client_config.current.object_id]
}
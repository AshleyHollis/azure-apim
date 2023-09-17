terraform {
  cloud {
    organization = "AshleyHollis"
    hostname = "app.terraform.io" # Optional; defaults to app.terraform.io

    workspaces {
      name = "azure-apim-infra"
    }
  }
}

remote_state {
  backend = "azurerm" 
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name   = "dev-mateo"
    storage_account_name  = "alterraformstate"
    container_name        = "tfstate"
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    subscription_id       = get_env("subscription_id")
    client_id             = get_env("client_id")
    client_secret         = get_env("client_secret")
    tenant_id             = get_env("tenant_id")
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${get_env("subscription_id")}"
  tenant_id       = "${get_env("tenant_id")}"
  client_id       = "${get_env("client_id")}"
  client_secret   = "${get_env("client_secret")}"
}
EOF
}
remote_state {
  backend = "azurerm" 
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name   = "Al-Resource-Group-Common"
    storage_account_name  = "arrivelogisticsterraform"
    container_name        = "tfstate"
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    subscription_id       = get_env("SUBSCRIPTION_ID")
    client_id             = get_env("CLIENT_ID")
    client_secret         = get_env("CLIENT_SECRET")
    tenant_id             = get_env("TENANT_ID")
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${get_env("SUBSCRIPTION_ID")}"
  tenant_id       = "${get_env("TENANT_ID")}"
  client_id       = "${get_env("CLIENT_ID")}"
  client_secret   = "${get_env("CLIENT_SECRET")}"
}
EOF
}
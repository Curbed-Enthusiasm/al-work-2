remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name   = "Al-Resource-Group-Common"
    storage_account_name  = "arrivelogisticsterraform"
    container_name        = "centralized-infra"
    key                   = "AKSClustersInfra/${path_relative_to_include()}/terraform.tfstate"
  }
}

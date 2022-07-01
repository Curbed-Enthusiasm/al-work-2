terraform {
  backend "azurerm" {
    resource_group_name   = "Al-Resource-Group-Common"
    storage_account_name  = "arrivelogisticsterraform"
    container_name        = "azure-app-infra"
  }
}
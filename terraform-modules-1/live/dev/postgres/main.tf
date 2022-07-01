# terraform written in by the mats
# 06.04.2021
# this calls the previously written modules and runs them
# 
# future state add variables ᕦ(ò_óˇ)ᕤ make stronk

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
  }
}



data "azurerm_client_config" "current" {}


module "al-postgres-mod-test" {
  source = "../../../postgres-module"
  pg-server-name = var.pg-server-name
  pg-db-name = var.pg-db-name
  resource_group_name = var.resource_group_name
  region = var.region
  env = var.env
  storage_amt = var.storage_amt # needs to be divisible by 1024 REEEEEEEE
  key_vault = var.key_vault
  subscription_id = var.subscription_id
}
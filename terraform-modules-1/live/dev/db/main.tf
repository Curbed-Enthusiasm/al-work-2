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

provider "azurerm" {
  features {}
  #subscription_id = "d91b642f-112b-472a-99e2-4000f15c844c"
}
# this may not be needed here
# provider "azurerm" {
#   alias           = "dev"
#   subscription_id = "d91b642f-112b-472a-99e2-4000f15c844c"
# }

data "azurerm_client_config" "current" {}


module "al-sqlserver-mod-test" {
  source = "../../../database-module"
  subscription_id = var.subscription_id
  sql-server-name = var.sql-server-name
  sql-db-name = var.sql-db-name
  resource_group_name = var.resource_group_name   #"tf-matts-test"
  region = var.region
  env = var.env
  key_vault = var.key_vault  #"Matts-Keys-TF"
}
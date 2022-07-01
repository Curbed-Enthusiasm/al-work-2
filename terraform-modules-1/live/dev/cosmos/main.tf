# terraform written in by the mats
# 06.04.2021
# this calls the previously written modules and runs them
# 
# future state add variables ᕦ(ò_óˇ)ᕤ make stronk

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}


module "al-cosmos-mod" {
  source = "../../../cosmos-db-module"
  #subscription_id = var.subscription_id
  resource_group_name = var.resource_group_name   #"tf-matts-test"
  region = var.region  # also used for location
  failover_location = var.failover_location
  key_vault = var.key_vault  #"Matts-Keys-TF"
  purpose_tag = var.purpose_tag
  owner_tag = var.owner_tag
  cosmos_container = var.cosmos_container
}
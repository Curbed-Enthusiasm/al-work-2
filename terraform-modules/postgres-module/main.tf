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
  subscription_id = var.subscription_id
}

# commented out but may need as we figure out accessing develop subscription

# provider "azurerm" {
#   subscription_id = "${var.azure-subscription_id}"
#   client_id       = "${var.azure-client_id}"
#   client_secret   = "${var.azure-client_secret}"
#   tenant_id       = "${var.azure-tenant_id}"
# }

#~~~~~~~~~~~~ Data Section

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "key_vault" {  # pulls in the specified keyVault
  name                = var.key_vault
  resource_group_name = var.resource_group_name
}

# checking to see if a server already exists that they want to use
data "azurerm_postgresql_server" "postgres-server" {
  name                = var.pg-server-name
  resource_group_name = var.resource_group_name
  count               = var.pg_server_is_new ? 0 : 1
}

#~~~~~~~~~~~~ this creates a random password, stores then retrieves the value for use (kinda hacky DON'T JUDGE ME (ง '̀-'́)ง )

resource "random_password" "password" {
  length      = 20
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

resource "azurerm_key_vault_secret" "generated_pass" {
  name         = "admin-pwd"
  value        = random_password.password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

# removed the data pulling back secret, instead just also used it in 
# db creation, see below

#~~~~~~~~~~~~~~~ PostgreSQL Server/DB 

resource "azurerm_postgresql_server" "al-postgres-server" {
  name                = var.pg-server-name
  location            = var.region
  resource_group_name = var.resource_group_name

  sku_name            = var.env == "prod" ? "GP_Gen5_4" : "B_Gen5_2" # {pricing tier}{compute generation}{vCores} in this case
                        # B (basic)_Gen5_(cpu generation)2 (2 vCores)

  storage_mb                   = var.storage_amt # must be in 1024 increments starting at 5120
  backup_retention_days        = var.env == "prod" ? 21 : 7
  geo_redundant_backup_enabled = false # should this be standardized?
  auto_grow_enabled            = true 

  administrator_login          = "pg4dm1n_Us3r"
  administrator_login_password = "${azurerm_key_vault_secret.generated_pass.value}"
  version                      = var.version
  ssl_enforcement_enabled      = true

  tags = {
    environment       = var.env
    purpose           = var.purpose_tag
    owner             = var.owner_tag
  }
}

resource "azurerm_postgresql_database" "al-postgres-db" {
  name                = var.pg-db-name
  resource_group_name = var.resource_group_name
  server_name         = var.pg-server-name
  charset             = var.charset # should this be standardized?
  collation           = "English_United States.1252" # should this be standardized?
}
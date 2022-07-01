terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 3.10"
    }
  }
}

data "azurerm_client_config" "current" {}


#~~~~~~~~~~~~ Data Section

# likely should exist before running this module, or in conjunction with a module that will create one
data "azurerm_key_vault" "key_vault" {  # pulls in the specified keyVault
  name                = var.key_vault
  resource_group_name = var.resource_group_name
  count               = var.key_vault_is_new ? 0 : 1
}
# checking to see if a server already exists that they want to use
data "azurerm_sql_server" "sql-server" {
  name                = var.sql_server_name
  resource_group_name = var.server_resource_group_name
  count               = var.sql_server_is_new ? 0 : 1
}
# removed storage stuff, was not used when spinning up DBs manually

# removed generated and stored password due to likely little use

# removed the data pulling back secret, instead just also used it in 
# db creation, see below

#~~~~~~~~~~~~ SQL DB # server infra should be in a separate module. removing tags to add in infra 


resource "azurerm_sql_database" "al-sql-db" {
  name                        = var.sql_db_name
  resource_group_name         = var.resource_group_name
  location                    = var.region
  server_name                 = var.sql_server_name
  create_mode                 = "Default"
  edition                     = "Standard"
  
  count                       = var.elastic_pool_name == "" ? 1: 0
  elastic_pool_name           = var.elastic_pool_name 
}
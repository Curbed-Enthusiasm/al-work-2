terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "key_vault" {  # pulls in the specified keyVault
  name                = var.key_vault
  resource_group_name = var.resource_group_name
}

# help name the accounts and cut down on variables
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# create the account for everything to live in

resource "azurerm_cosmosdb_account" "al-cosmos-account" {
  name                = "al-cosmos-account-${random_integer.ri.result}"
  location            = var.region
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4" # may want to put this in a variable if they're gonna use other DB formats?
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  geo_location {
    location          = var.region
    failover_priority = 0
  }

  tags = {
    purpose           = var.purpose_tag
    owner             = var.owner_tag
  }
}

# create the db for the containers to live in (plain sql is recommended)
resource "azurerm_cosmosdb_sql_database" "al-cosmos-db" {
  name                = "al-cosmos-db-${random_integer.ri.result}"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.al-cosmos-account.name
  throughput          = 400
}


# create the container for the data to live in
resource "azurerm_cosmosdb_sql_container" "al-cosmos-container" {
  name                  = var.cosmos_container
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.al-cosmos-account.name
  database_name         = azurerm_cosmosdb_sql_database.al-cosmos-db.name
  partition_key_path    = var.partition_key
  partition_key_version = 1
  throughput            = 400

  indexing_policy {
    indexing_mode = "Consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}

# take the endpoint and key and put in vault for consumption

resource "azurerm_key_vault_secret" "cdb-endpoint" {
  name         = "cosmos-endpoint"
  value        = azurerm_cosmosdb_account.al-cosmos-account.endpoint
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "cdb-primary-key" {
  name         = "cosmos-pkey"
  value        = azurerm_cosmosdb_account.al-cosmos-account.primary_key
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
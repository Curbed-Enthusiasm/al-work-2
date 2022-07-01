output "endpoint" {
  value = azurerm_cosmosdb_account.al-cosmos-account.endpoint
}

output "primary_key" {
  value = azurerm_cosmosdb_account.al-cosmos-account.primary_key
  sensitive = true
}

output "db_id" {
  value = azurerm_cosmosdb_sql_database.al-cosmos-db.id
}

output "container_id" {
  value = azurerm_cosmosdb_sql_container.al-cosmos-container.id
}

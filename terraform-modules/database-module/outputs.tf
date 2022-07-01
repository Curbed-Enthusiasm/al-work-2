output "db_name" {
  value = azurerm_sql_database.al-sql-db[count.index].name
}

output "id" {
  value = azurerm_sql_database.al-sql-db[0].id
}
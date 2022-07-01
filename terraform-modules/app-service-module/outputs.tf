output "app_service_id" {
  value = azurerm_app_service.app_service.id
}

output "app_service_principal_id" {
  value = azurerm_app_service.app_service.identity.0.principal_id
}

output "key_vault_id" {
  value = var.key_vault_is_new ? var.key_vault : data.azurerm_key_vault.key_vault[0].id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "hostname" {
  value = azurerm_app_service.app_service.default_site_hostname
}
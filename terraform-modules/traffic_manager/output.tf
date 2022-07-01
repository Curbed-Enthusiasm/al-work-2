output "profile_id" {
  value = azurerm_traffic_manager_profile.traffic_profile.id
}

output "profile_fqdn" {
  value = azurerm_traffic_manager_profile.traffic_profile.fqdn
}
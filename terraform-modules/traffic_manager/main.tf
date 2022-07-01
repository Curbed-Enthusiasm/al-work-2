terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.74.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_traffic_manager_profile" "traffic_profile" {
  name                   = var.profile_name
  resource_group_name    = var.profile_resource_group
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = var.profile_name
    ttl           = var.ttl
  }

  monitor_config {
    protocol                     = var.protocol
    port                         = var.port
    path                         = var.path
    interval_in_seconds          = var.interval_in_seconds
    timeout_in_seconds           = var.timeout_in_seconds
    tolerated_number_of_failures = var.tolerated_number_of_failures
  }
}

data "azurerm_app_service" "app" {
  count               = length(var.apps_to_route)
  name                = var.apps_to_route[count.index]["name"]
  resource_group_name = var.apps_to_route[count.index]["rg"]
}

resource "azurerm_traffic_manager_endpoint" "endpoint_app" {
  count               = length(var.apps_to_route)
  name                = var.apps_to_route[count.index]["name"]
  resource_group_name = var.profile_resource_group
  profile_name        = azurerm_traffic_manager_profile.traffic_profile.name
  type                = "azureEndpoints"
  target_resource_id  = data.azurerm_app_service.app[count.index].id
  weight              = var.apps_to_route[count.index]["weight"]
}

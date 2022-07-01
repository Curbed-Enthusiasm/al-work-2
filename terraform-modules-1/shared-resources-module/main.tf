#~~~~~~~~~~~~ Shared Resources Modules: Container Pool and Service Bus
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
  }
}



resource "azurerm_container_registry" "al-acr" {
  name                     = var.acr_name
  resource_group_name      = var.resource_group_name
  location                 = var.region
  sku                      = "Premium" # should this be standardized?
  admin_enabled            = false
  georeplication_locations = ["East US", "West Europe"] # replication for dev/test/stage?
}

resource "azurerm_servicebus_namespace" "al-resource-bus" {
  name                = var.servicebus_namespace
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  tags = {
    source = "terraform"
  }
}

resource "azurerm_servicebus_queue" "al-resource-queue" {
  name                = var.servicebus_queue_name
  resource_group_name = azurerm_resource_group.example.name
  namespace_name      = azurerm_servicebus_namespace.example.name

  enable_partitioning = true
}
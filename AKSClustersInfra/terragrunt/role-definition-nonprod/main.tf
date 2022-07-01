terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

variable "subscription_id" {
default = "2391022b-04f5-42a5-838d-1c0a301df4c8"
}

variable "resource_group_name" {
  default = "aks-cluster-nonprod"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "aks" {
  name = var.resource_group_name
}

resource "azurerm_role_definition" "admin" {
  name        = "${var.resource_group_name}-admin-role"
  scope       = data.azurerm_resource_group.aks.id
  description = "Resource group level admin role for ${var.resource_group_name}"

  permissions {
    actions     = ["*"]
    not_actions = []
  }
  assignable_scopes = [
    data.azurerm_resource_group.aks.id
  ]
}

data "azuread_client_config" "current" {}

resource "azuread_group" "admin" {
  display_name     = "${var.resource_group_name}-SRE"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "controlledchaos" {
  group_object_id  = azuread_group.admin.id
  member_object_id = "136c7f29-c179-4083-ac4a-eb9348584e32"
}

resource "azurerm_role_assignment" "admin" {
  scope                = data.azurerm_resource_group.aks.id
  role_definition_id   = azurerm_role_definition.admin.role_definition_resource_id
  principal_id         = azuread_group.admin.object_id
}

resource "azurerm_role_assignment" "cicd" {
  scope                = data.azurerm_resource_group.aks.id
  role_definition_id   = azurerm_role_definition.admin.role_definition_resource_id
  principal_id         = "75df5c5b-534b-4cb9-b560-1f22706fd020"
}

output "azuread_group" {
  value = azuread_group.admin.object_id
}

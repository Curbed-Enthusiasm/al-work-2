terraform {
  required_providers {
    azurerm = {
      source    = "hashicorp/azurerm"
      version   = "=2.46.0"

    }
  }
}

provider "azurerm" {
  features {}
}
# pulling in an app service plan if it exists
data "azurerm_app_service_plan" "app_service_plan" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  count               = var.service_plan_is_new ? 0 : 1
}

# pulling in key vault
data "azurerm_key_vault" "al-akv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}


# setting up service plan if it needs a new one
resource "azurerm_app_service_plan" "service_plan" {
  name                = var.service_plan_name
  location            = var.region
  resource_group_name = var.resource_group_name
  kind                = var.service_plan_kind
  reserved            = var.service_plan_kind == "Linux" ? true : var.service_plan_reserved
  count               = var.service_plan_is_new ? 1 : 0

  sku {
    tier = var.service_plan_tier
    size = var.service_plan_size
  }
  depends_on = [
    azurerm_resource_group.resource_group
  ]
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.region
  count    = var.resource_group_is_new ? 1 : 0
}

# Setting up AKS cluster
resource "azurerm_kubernetes_cluster" "al-k8s-cluster" {
  name                = "${var.prefix}-k8s-cluster"
  location            = var.region
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name                = "${var.prefix}k8s"
    node_count          = var.node_count
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    max_count           = var.max_node_count
    min_count           = var.min_node_count
  }

  identity {
    type = "SystemAssigned"
  }

  # addon_profile {
  #   azure-keyvault-secrets-provider {
  #   enabled = true
  # }
  # }

  tags = {
    environment     = var.env
    purpose         = var.purpose_tag
    owner           = var.owner_tag
  }
}

resource "azurerm_role_assignment" "akv_kubelet" {
  scope                = data.azurerm_key_vault.al-akv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_kubernetes_cluster.al-k8s-cluster.kubelet_identity[0].object_id
}

# may comment out, left over from chris' files
# resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {

#   depends_on = [azurerm_app_service_plan.service_plan]
#   count = length(azurerm_app_service_plan.service_plan)

#   name = "${azurerm_app_service_plan.service_plan[count.index].name}-as_settings"
#   resource_group_name = var.resource_group_name
#   location = var.location
#   target_resource_id = azurerm_app_service_plan.service_plan[count.index].id

#  profile {
#     name = "CpuProfile"

#     capacity {
#       default = var.min_agent_count
#       minimum = var.min_agent_count
#       maximum = var.max_agent_count
#     }

#     rule {
#       metric_trigger {
#         metric_name        = "CpuPercentage"
#         metric_resource_id = azurerm_app_service_plan.service_plan[count.index].id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT5M"
#         time_aggregation   = "Average"
#         operator           = "GreaterThan"
#         threshold          = 75
#       }

#       scale_action {
#         direction = "Increase"
#         type      = "ChangeCount"
#         value     = "1"
#         cooldown  = "PT1M"
#       }
#     }

#     rule {
#       metric_trigger {
#         metric_name        = "CpuPercentage"
#         metric_resource_id = azurerm_app_service_plan.service_plan[count.index].id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT5M"
#         time_aggregation   = "Average"
#         operator           = "LessThan"
#         threshold          = 45
#       }

#       scale_action {
#         direction = "Decrease"
#         type      = "ChangeCount"
#         value     = "1"
#         cooldown  = "PT1M"
#       }
    
  
  

#     }
#   }
# }

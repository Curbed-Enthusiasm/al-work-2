terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_app_service_plan" "app_service_plan" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  count               = var.service_plan_is_new ? 0 : 1
}

# resource "azurerm_app_service_plan" "service_plan" {
#   name                = var.service_plan_name
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   kind                = var.service_plan_kind
#   reserved            = var.service_plan_kind == "Linux" ? true : var.service_plan_reserved
#   count               = var.service_plan_is_new ? 1 : 0

#   sku {
#     tier = var.service_plan_tier
#     size = var.service_plan_size
#   }
#   depends_on = [
#     azurerm_resource_group.resource_group
#   ]
# }

locals {
  hostname = "https://${var.app_service_name}.azurewebsites.net"
  stg_prod_log_categories = ["AppServiceFileAuditLogs", "AppServiceAntivirusScanAuditLogs"]
  is_upper_env = lower(var.env) == "prod" || lower(var.env) == "stg"
}

resource "azurerm_app_service" "app_service" {
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.region
  app_service_plan_id = var.service_plan_is_new ? var.service_plan_name : data.azurerm_app_service_plan.app_service_plan[0].id
  https_only          = true
  identity {
    type = "SystemAssigned"
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
  site_config {
    cors {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = var.cors_support_credentials
    }
  }

  app_settings = var.app_service_settings

  tags = merge(var.app_service_tags, {
    environment = var.env
  })

  lifecycle {
    ignore_changes = [ app_settings, tags ]
  }
}

resource "azurerm_app_service_slot" "slot" {
  name                = "${var.app_service_name}-slot"
  app_service_name    = azurerm_app_service.app_service.name
  location            = azurerm_app_service.app_service.location
  resource_group_name = azurerm_app_service.app_service.resource_group_name
  app_service_plan_id = azurerm_app_service.app_service.app_service_plan_id
  count               = local.is_upper_env ? 1 : 0
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault
  resource_group_name = var.resource_group_name
  count               = var.key_vault_is_new ? 0 : 1
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = var.key_vault_is_new ? var.key_vault : data.azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_app_service.app_service.identity.0.principal_id

  secret_permissions      = var.key_vault_secret_permissions
  key_permissions         = var.key_vault_key_permissions
  certificate_permissions = var.key_vault_certificate_permissions
}

resource "azurerm_monitor_diagnostic_setting" "log_fwding" {
  name = "newrelic-logs"
  target_resource_id = azurerm_app_service.app_service.id
  # Using hardcoded auth rule id for now since we use a single shared event hub for all logs regardless of environment.
  # This may need to be made dynamic based on some data lookup in the future.
  eventhub_authorization_rule_id = "/subscriptions/2391022b-04f5-42a5-838d-1c0a301df4c8/resourceGroups/Al-Resource-Group-Common/providers/Microsoft.EventHub/namespaces/al-logevents-${var.region}/authorizationRules/RootManageSharedAccessKey"
  eventhub_name = "logs"

  // Enabled log categories
  log {
    category = "AppServiceConsoleLogs"

    retention_policy {
      days = 3
      enabled = true
    }
  }

  log {
    category = "AppServiceAppLogs"

    retention_policy {
      days = 3
      enabled = true
    }
  }

  // Disabled log/metric categories. Azure creates them and sets them to disabled automatically, so if
  // not included they get detected as changes on each subsequent plan, getting deleted then recreated as
  // disabled each apply
  log {
    category = "AppServiceAuditLogs"
    enabled  = false

    retention_policy {
        days    = 0
        enabled = false
    }
  }

  log {
      category = "AppServiceHTTPLogs"
      enabled  = false

      retention_policy {
          days    = 0
          enabled = false
      }
  }

  log {
      category = "AppServiceIPSecAuditLogs"
      enabled  = false

      retention_policy {
          days    = 0
          enabled = false
      }
  }
  log {
      category = "AppServicePlatformLogs"
      enabled  = false

      retention_policy {
          days    = 0
          enabled = false
      }
  }

  metric {
      category = "AllMetrics"
      enabled  = false

      retention_policy {
          days    = 0
          enabled = false
      }
  }

  // The categories below only appear for premium app svc plans, so dynamically generate them as disabled
  // when appropriate based on environment
  dynamic "log" {
    for_each = local.is_upper_env ? local.stg_prod_log_categories : []
    content {
      category = log.value
      enabled  = false

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
}


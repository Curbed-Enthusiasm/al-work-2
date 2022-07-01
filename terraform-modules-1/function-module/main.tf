terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 3.10"
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_app_service_plan" "app_service_plan" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  count               = var.service_plan_is_new ? 0 : 1
}

locals {
  is_upper_env = lower(var.env) == "prod" || lower(var.env) == "stg"
}

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

# checking to see if a storage account already exists that they want to use
data "azurerm_storage_account" "storage_acct" {
  name                = var.storage_acct_name
  resource_group_name = var.resource_group_name
  count               = var.storage_acct_is_new ? 0 : 1
}

# creating function app
resource "azurerm_function_app" "function_app" {
  name                       = var.function_name
  location                   = var.region
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = var.service_plan_is_new ? azurerm_app_service_plan.service_plan[0].id : data.azurerm_app_service_plan.app_service_plan[0].id
  storage_account_name       = var.storage_acct_name
  storage_account_access_key = var.storage_acct_is_new ? azurerm_storage_account.al-storage-acct[0].primary_access_key : data.azurerm_storage_account.storage_acct[0].primary_access_key
  os_type                    = var.os_type
  version                    = "~3"
  https_only                 = var.https_only

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = 1
    "FUNCTIONS_WORKER_RUNTIME" = var.func_runtime_lang
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.ai[0].instrumentation_key
    "CustomApplicationInsightsTelemetryKey" = azurerm_application_insights.ai[0].instrumentation_key
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }

  site_config {
    always_on                = true
    linux_fx_version         = "PYTHON|3.8"
    ftps_state               = var.ftps_state
  }

  tags = {
    environment       = var.env
    purpose           = var.purpose_tag
    owner             = var.owner_tag
  }

}

resource "azurerm_function_app_slot" "slot" {
  count                      = local.is_upper_env ? 1 : 0

  name                       = "swap"
  location                   = azurerm_function_app.function_app.location
  resource_group_name        = azurerm_function_app.function_app.resource_group_name
  app_service_plan_id        = azurerm_function_app.function_app.app_service_plan_id
  function_app_name          = azurerm_function_app.function_app.name
  storage_account_name       = azurerm_function_app.function_app.storage_account_name
  storage_account_access_key = azurerm_function_app.function_app.storage_account_access_key

  os_type                    = var.os_type
  version                    = "~3"
  https_only                 = var.https_only

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = 1
    "FUNCTIONS_WORKER_RUNTIME" = var.func_runtime_lang
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.ai[0].instrumentation_key
    "CustomApplicationInsightsTelemetryKey" = azurerm_application_insights.ai[0].instrumentation_key
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }

  site_config {
    always_on                = true
    linux_fx_version         = "PYTHON|3.8"
    ftps_state               = var.ftps_state
  }

  tags = {
    environment       = var.env
    purpose           = var.purpose_tag
    owner             = var.owner_tag
  }
}

# creating storage_account based on environment deployed to
resource "azurerm_storage_account" "al-storage-acct" {
  name                     = var.storage_acct_name
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = var.env == "prod" ? "Premium" : "Standard"
  account_replication_type = var.env == "prod" ? "ZRS" : "LRS"
  count                    = var.storage_acct_is_new ? 1 : 0

  tags = {
    environment       = var.env
    purpose           = var.purpose_tag
    owner             = var.owner_tag
  }

  depends_on = [
    azurerm_resource_group.resource_group
  ]

}

# create app insights monitoring
resource "azurerm_application_insights" "ai" {
  name                = "${var.function_name}-ai"
  location            = var.region
  resource_group_name = var.resource_group_name
  application_type    = "web"
  count               = var.include_app_insights ? 1 : 0
}
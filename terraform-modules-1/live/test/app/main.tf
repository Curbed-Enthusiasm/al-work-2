
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
  }
}



data "azurerm_client_config" "current" {}


module "commited_capacity_test" {
  source = "../../../app-service-module"
  service_plan_name = "Al-Shared-Linux-TEST-Central-US-Plan-2"
  key_vault = "Al-Key-Vault-TEST-SC-US"
  app_service_settings = {
    DOCKER_CUSTOM_IMAGE_NAME = var.ui_docker_custom_image_name
    DOCKER_REGISTRY_SERVER_PASSWORD = var.ui_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL = var.ui_docker_registry_server_url
    DOCKER_REGISTRY_SERVER_USERNAME = var.ui_docker_registry_server_username
    NEW_RELIC_APP_NAME = var.ui_new_relic_app_name
    NEW_RELIC_LICENSE = var.ui_new_relic_license
    OKTA_AUTH_SERVER_ID = var.ui_okta_auth_server_id
    OKTA_BASE = var.ui_okta_base
    OKTA_CLIENT_ID = var.ui_okta_client_id
    OKTA_ISSUER = var.ui_okta_issuer
    OKTA_PRODUCT = var.ui_okta_product
    OKTA_REDIRECT_URI = var.ui_okta_redirect_uri
    OKTA_TESTING_DISABLE_HTTPS_CHECK = var.ui_okta_testing_disable_https_check
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = var.ui_websites_enable_app_service_storage
  }
  resource_group_name = "Al-Resource-Group-Test"
  app_service_name = "al-committedcapacity-test-central"
  region = "centralus"
  key_vault_key_permissions = []
  key_vault_certificate_permissions = []
  key_vault_secret_permissions = ["Get", "List"]
  app_service_tags = {}
  env = "Test"
}

module "commited_capacity_svc_test" {
  source = "../../../app-service-module"
  service_plan_name = "Al-Shared-Linux-TEST-Central-US-Plan-2"
  key_vault = "Al-Key-Vault-TEST-SC-US"
  app_service_settings = {
    DOCKER_CUSTOM_IMAGE_NAME = var.svc_docker_custom_image_name
    DOCKER_REGISTRY_SERVER_PASSWORD = var.svc_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL = var.svc_docker_registry_server_url
    DOCKER_REGISTRY_SERVER_USERNAME = var.svc_docker_registry_server_username
    KeyVault__VaultName = var.svc_keyvault__vaultname
  }
  resource_group_name = "Al-Resource-Group-Test"
  app_service_name = "al-CommittedCapacitySvc-test-central"
  region = "centralus"
  key_vault_key_permissions = []
  key_vault_certificate_permissions = []
  key_vault_secret_permissions = ["Get", "List"]
  app_service_tags = {}
  env = "Test"
}
locals {
    key_vault_name = "al-${var.sql_db_name_short}-${var.env}-${substr(var.region_display, 0, 1)}"
    resource_group_name = "${var.resource_group_name_base}-${var.env}"
}

data "azurerm_client_config" "current" {}

# also added and RG to group any potential future resorces necessary
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.region_code
}

resource "azurerm_key_vault" "key_vault" {
    name = local.key_vault_name
    location = var.region_code
    resource_group_name = local.resource_group_name
    enabled_for_disk_encryption = true
    tenant_id = data.azurerm_client_config.current.tenant_id
    sku_name = "standard"
    depends_on = [
      azurerm_resource_group.rg
    ]
}

#~~~~~~~~~~~~ this creates a random password, stores then retrieves the value for use (kinda hacky DON'T JUDGE ME (ง '̀-'́)ง )

# resource "random_password" "password" {
#   length      = 20
#   min_upper   = 2
#   min_lower   = 2
#   min_numeric = 2
#   min_special = 2
# }

# resource "azurerm_key_vault_secret" "generated_pass" {
#   name         = var.pass_name
#   value        = random_password.password.result
#   key_vault_id = azurerm_key_vault.key_vault.id
#   depends_on = [
#     azurerm_key_vault_access_policy.automationAccess
#   ]
# }

# resource "azurerm_key_vault_access_policy" "automationAccess" {
#   key_vault_id = azurerm_key_vault.key_vault.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   secret_permissions = [
#     "delete",
#     "get",
#     "set",
#   ]
# }

module "db_automation" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//database-module?ref=dbFixerUpper"
  sql_server_name = var.sql_server_name
  sql_db_name = "al-${var.sql_db_name}-${var.env}"
  resource_group_name = var.server_resource_group_name
  server_resource_group_name = var.server_resource_group_name
  # db_user = var.pass_name # internal user for team automation needed on all DBs
  region = var.region_code
  env = var.env
  key_vault = azurerm_key_vault.key_vault.id 
  key_vault_is_new = true
  elastic_pool_name = var.env == "prod" ? null : var.elastic_pool_name
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# Embed provision script in TF???
# Support identities for DB Administration add in to module
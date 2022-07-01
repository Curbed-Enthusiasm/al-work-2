remote_state {
  backend = "azurerm" 
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name   = "Al-Resource-Group-Common"
    storage_account_name  = "arrivelogisticsterraform"
    container_name        = "centralized-infra"
    key                   = "dbAutomationTest/${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

generate "variables" {
  path = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
variable "sql_db_name" {
  type = string
}

variable "sql_db_name_short" {
  type = string
}

variable "resource_group_name_base" {
  type = string
}

variable "env" {
  type = string
}

variable "region_code" {
  type = string
}

variable "region_display" {
  type = string
}

variable "pass_name" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "server_resource_group_name" {
  type = string
}

variable "elastic_pool_name" {
  type = string
}


variable "tags" {
  type = map(string)
}
EOF
}

inputs = {
  resource_group_name_base    = "Al-RG"
  sql_db_name                 = "TestAutomationDB"
  sql_db_name_short           = "TestAutoDB"
  region_code                 = "centralus"
  region_display              = "Central"
  pass_name                   = "TestPass"
  sql_server_name             = "alsqldb01"
  elastic_pool_name           = "AccelrateNonProd"
  server_resource_group_name  = "ProductionSQL"


  tags = {
    provisioner = "Terraform"
    team = "controlled-chaos"
    purpose = "automated infra testing"
  }
}
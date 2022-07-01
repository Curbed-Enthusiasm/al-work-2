variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
}

variable "server_resource_group_name" {
  description = "Azure resource group of the sql server"
  type        = string
}

variable "key_vault" {
  description = "Name of the key vault containing the secrets for the App Service"
  type        = string
}

variable "pass_name" {
  description = "name of password stored in KV"
  type        = string
  default     = "Admin-pwd"
}

variable "sql_server_name" {
  description = "Azure SQL Server name"
  type        = string
}

variable "sql_db_name" {
  description = "Azure SQL Database name"
  type        = string
}

variable "elastic_pool_name" {
  description = "name of elastic pool for db"
  type        = string
}

variable "env" {
    description = "Environment being deployed"
    type        = string
}

variable "purpose_tag" {
  description = "what is this and why does it exist"
  type        = string
  default     = "testing"
}

variable "owner_tag" {
  description = "which team is using this"
  type        = string
  default     = "controlledChaos"
}

variable "sql_server_is_new" {
  description = "Indicates whether or not the sql server to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

variable "key_vault_is_new" {
  description = "Indicates whether or not the KV to use has to be created. Defaults to false"
  type        = bool
  default     = false
}

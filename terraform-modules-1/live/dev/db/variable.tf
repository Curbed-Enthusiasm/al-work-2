variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
}

variable "key_vault" {
  description = "Name of the key vault containing the secrets for the App Service"
  type        = string
}

variable "sql-server-name" {
  description = "Azure SQL Server name"
  type        = string
}

variable "sql-db-name" {
  description = "Azure SQL Database name"
  type        = string
}

variable "env" {
    description = "Environment being deployed"
    type        = string
}

variable "subscription_id" {
    description = "Azure Subscription ID to deploy into"
    type        = string
}
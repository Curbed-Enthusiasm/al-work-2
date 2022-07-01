variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
}

variable "env" {
    description = "Environment being deployed"
    type        = string
}

variable "key_vault" {
  description = "Name of the key vault containing the secrets for the App Service"
  type        = string
}

variable "storage_amt" {
    description = "Amount of storage for DB in MB"
    type        = number
}

variable "pg-server-name" {
  description = "Azure PostgreSQL Server name"
  type        = string
}

variable "pg-db-name" {
  description = "Azure PostgreSQL DB name"
  type        = string
  default     = "test"
}

variable "subscription_id" {
    description = "Azure Subscription ID to deploy into"
    type        = string
}
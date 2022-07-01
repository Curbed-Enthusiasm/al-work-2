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

variable "env" {
    description = "Environment being deployed"
    type        = string
}

variable "storage_amt" {
    description = "Amount of storage for DB in MB minimum of 5120 MUST BE in 1024 increments"
    type        = number
}

variable "pg-server-name" {
  description = "Azure PostgreSQL Server name"
  type        = string
}

variable "pg-db-name" {
  description = "Azure PostgreSQL DB name"
  type        = string
}

variable "charset" {
  description = "Azure PostgreSQL character set"
  type        = string
  default     = "UTF8"
}

variable "version" {
  description = "Azure PostgreSQL version number. Valid versions are: 10, 10.0, 10.2,11,9.5,9.6"
  type        = string
  default     = "9.6"
}

variable "subscription_id" {
    description = "subscription to deploy to"
    type        = string
    #default     = "d91b642f-112b-472a-99e2-4000f15c844c"
}

variable "pg_server_is_new" {
  description = "Indicates whether or not the postgres server to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

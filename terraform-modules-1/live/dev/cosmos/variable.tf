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

variable "failover_location" {
  description = "location / region for failover"
  type        = string
}

variable "purpose_tag" {
  description = "what is this and why does it exist"
  type        = string
}

variable "owner_tag" {
  description = "which team is using this"
  type        = string
}

variable "cosmos_container" {
  description = "Name for the cosmos container"
  type        = string
}
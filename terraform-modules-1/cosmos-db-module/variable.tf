variable "region" {
  description = "Azure location / region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
  default     = "Dev-Matts"
}

variable "key_vault" {
  description = "Name of the key vault containing the secrets for the App Service"
  type        = string
  default     = "Matts-Keys"
}

variable "failover_location" {
  description = "location / region for failover"
  type        = string
  default     = "centralus"
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

variable "cosmos_container" {
  description = "Name for the cosmos container"
  type        = string
  default     = "test-container"
}

variable "partition_key" {
  description = "Name for the cosmos partition key"
  type        = string
  default     = "test-partition"
}
variable "subscription_id" {
  description = "Azure subscription id"
  type        = string
}

variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "key_vault_name" {
  description = "Azure key vault for AKS Secrets"
  type        = string
}


variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
}

variable "resource_group_is_new" {
  description = "Indicates whether or not the resource group to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

variable "env" {
    description = "environment being deployed"
    type        = string
}

# *********************************
# AKS Cluster Section
variable "prefix" {
    description = "prefix for infra"
    type        = string
}

variable "node_count" {
    description = "number of nodes to start the cluster with"
    type = number
}

variable "max_node_count" {
    description = "max number of nodes in cluster between 1 - 1000"
    type = number
}

variable "min_node_count" {
    description = "min number of nodes in cluster between 1 - 1000"
    type = number
}

# *********************************
# Service Plan Section
variable "service_plan_is_new" {
  description = "Indicates whether or not the app service plan to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

variable "service_plan_name" {
  description = "Name of the App Service Plan the App Service will be in"
  type        = string
}

variable "service_plan_kind" {
  description = "Kind of App Service to create (Windows or Linux). Defaults to linux"
  type        = string
  default     = "Linux"
}

variable "service_plan_reserved" {
  description = "Is this app service plan reserved. Defaults to false, unless Linux kind."
  type        = bool
  default     = false
}

variable "service_plan_tier" {
  description = "Specifies the plan's pricing tier. (Basic, Standar, Premium)"
  type        = string
  default     = "Premium"
}

variable "service_plan_size" {
  description = "Specifies the plan's instance size"
  type        = string
  default     = "P1V2"
}

# *********************************
# Tags Section
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
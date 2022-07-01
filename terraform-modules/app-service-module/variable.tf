variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "app_service_settings" {
  description = "Settings the app service will have"
  type        = map
  default     = {}
}

variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
}

variable "app_service_name" {
  description = "Name of the app service resource that will be created"
  type        = string
}

variable "service_plan_name" {
  description = "Name of the App Service Plan the App Service will be in"
  type        = string
}

variable "app_service_tags" {
  description = "Tags for the app service resource"
  type        = map
  default     = {}
}

variable "key_vault" {
  description = "Name of the key vault containing the secrets for the App Service"
  type        = string
}

variable "key_vault_secret_permissions" {
  description = "List of permissions the policy gives to secrets"
  type        = list
  default     = []
}

variable "key_vault_key_permissions" {
  description = "List of permissions the policy gives to keys"
  type        = list
  default     = []
}

variable "key_vault_certificate_permissions" {
  description = "List of permissions the policy gives to certificates"
  type        = list
  default     = []
}

variable "env" {
  description = "Indicates the environment where this app service belongs, if 'prod' the app will have a slot"
  type        = string
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for this app through a browser"
  type        = list
  default     = []
}

variable "cors_support_credentials" {
  description = "Indicates whether or not the requests can be made using credentials. Defaults to false"
  type        = bool
  default     = false
}

variable "key_vault_is_new" {
  description = "Indicates whether or not the key vault to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

variable "service_plan_is_new" {
  description = "Indicates whether or not the app service plan to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

variable "key_vault_sku" {
  description = "Sku for the key vault in case it is created with the module"
  type        = string
  default    = "standard"
}

variable "service_plan_kind" {
  description = "Kind of App Service to create (Windows or Linux). Defaults to linux"
  type        = string
  default     = "Linux"
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

variable "service_plan_reserved" {
  description = "Is this app service plan reserved. Defaults to false, unless Linux kind."
  type        = bool
  default     = false
}

variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "storage_acct_name" {
  description = "Azure Storage Account name"
  type        = string
}

variable "storage_acct_is_new" {
  description = "Indicates whether or not the storage account to use have to be created. Defaults to false"
  type        = bool
  default     = false
}

variable "env" {
    description = "environment being deployed"
    type = string
}

variable "function_name" {
  description = "Azure Function name"
  type        = string
}

variable "os_type" {
    description = "the os for the function, blank for windows"
    type        = string
}

variable "run_time_lang" {
    description = "language function written in"
    type        = string
    default     = "python"
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

# tags section
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

variable "func_runtime_lang" {
  description = "what language is the function written in"
  type        = string
  default     = "python"
}

variable "https_only" {
  description = "Can the Function App only be accessed via HTTPS?"
  type        = bool
  default     = true
}

variable "ftps_state" {
  description = "State of FTP / FTPS service for this function app. Possible values include: AllAllowed, FtpsOnly and Disabled."
  type        = string
  default     = "FtpsOnly"
}

variable "include_app_insights" {
  description = "Include App Insights monitoring"
  type        = bool
  default     = true
}

variable "app_settings_ignore" {
  description = "List of app settings to be ignored by Terraform."
  type        = list
  default     = []
}
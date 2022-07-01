variable "region" {
  description = "Azure location / region"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group to house all of the resources created"
  type        = string
}

variable "acr_name" {
    description = "Azure Container Registry for shared resources"
    type = string
}
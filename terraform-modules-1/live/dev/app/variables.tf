variable "service_plan_name" {}
variable "key_vault" {}
variable "app_service_settings" {
  type = map(string)
}
variable "resource_group_name"{}
variable "app_service_name" {}
variable "region" {}
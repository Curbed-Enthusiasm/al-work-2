variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "region" {
  type        = string
  description = "Region for the resource group"
}

variable "budget" {
  type        = number
  description = "Amount of monthly money limit"
}

variable "contact_emails" {
  type        = list
  description = "List of mails to contact if the budget reaches the threshhold" 
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.64.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "${var.resource_group_name}-budget"
  resource_group_id = azurerm_resource_group.rg.id
  amount            = var.budget
  time_grain        = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-'01T00:00:00Z'",timestamp())
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"
    contact_emails = var.contact_emails
  }
}

resource "azurerm_role_definition" "role" {
  name        = "${var.resource_group_name}-access-role"
  scope       = azurerm_resource_group.rg.id
  description = "This is a custom role created via Terraform"

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
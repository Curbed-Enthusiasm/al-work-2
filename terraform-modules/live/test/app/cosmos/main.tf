terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.95.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    
  }
    subscription_id = "2391022b-04f5-42a5-838d-1c0a301df4c8"
  tenant_id       = "f3095ceb-7d38-45ad-b9ff-be8d55c6634b"
  client_id       = "52e10f6f-1565-4430-a36d-caad513f40dc"
  client_secret   = "j-DwS17XBE6vtAWBEDP_AHaJ7M.sqUxjjp"
}

resource "azurerm_app_service" "example" {
  name                = "al-quotesvc-prod-central"
  location            = "centralus"
  resource_group_name = "Al-Resource-Group-Prod"
  app_service_plan_id = azurerm_app_service_plan.service_plan.id
}


resource "azurerm_app_service_plan" "service_plan" {
  name                = "al-quotesvc-prod-central-plan"
  location            = "centralus"
  resource_group_name = "Al-Resource-Group-Prod"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Premium"
    size = "P1v2"
  }
}
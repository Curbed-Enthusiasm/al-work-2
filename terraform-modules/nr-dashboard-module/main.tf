# terraform written in by the mats
# 06.04.2021
# this calls the previously written modules and runs them
# 
# future state add variables ᕦ(ò_óˇ)ᕤ make stronk

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    newrelic = {
         source  = "newrelic/newrelic"
         version = ">= 2.12.0"
      }
  }
}

provider "newrelic" {
  api_key = "NRAK-VMHT8YJYKANQOQIILDB7B872JWB"
  account_id = 2801856
  region = "US"
}

resource "newrelic_one_dashboard" "dash-template" {
  name = "New Relic Terraform Starter"

  page {
    name = "New Relic Terraform Example" # Better title w/ variables for team name?

    widget_billboard {
      title = "Requests per minute" # working but very basic widget so they can see SOMEthing
      row = 1
      column = 1

      nrql_query {
        query       = "FROM Transaction SELECT rate(count(*), 1 minute)"
      }
    }

    widget_markdown {
      title = "Dashboard README"
      row    = 1
      column = 5

      text = "### Helpful Links\n\n* [New Relic One](https://one.newrelic.com)\n* [Developer Portal](https://developer.newrelic.com) --- ## Track your app Here"
    }
  }
}
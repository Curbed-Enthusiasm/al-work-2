# Introduction 
**Terraform Modules:** 
This will house all the modules used as the building blocks for the Infrastructure Platform

# Getting Started
What is here and how it's organized:
1.	Terraform Modules
    - split into 3 files: main.tf (defines the parts included in the module), outputs.tf (defines outputs after terraform stack is finished deploying), variables.tf (defines variables used)
2.	Live
    - split out by env and contains the files that call the modules as defined in the modules files, also consists of the same [3] file structure


# Module Docs

## App Service

```h
module "<Name of Resource>" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//app-service-module"
  service_plan_name = ""
  key_vault = ""
  app_service_settings = {
    ...
  }
  resource_group_name = ""
  app_service_name = ""
  region = ""
  key_vault_key_permissions = []
  key_vault_certificate_permissions = []
  key_vault_secret_permissions = []
  app_service_tags = {
    ...
  }
  env = ""


}
```

**source:**
The git  location of the module, the machine that executes needs to have acces throught SSH to the repository to run.

**app_service_name:**
The name of the App Service to create.

**service_plan_name:**
The name of the App Service Plan to use. If service_plan_is_new is set to true, this will try to create a new one.

**key_vault:**
The name of the Key Vault to link with the app service. If key_vault_is_new is set to true, this will try to create a new one.
If the keyv_vault_is_new is set to true this will need to be the id of the key_vault being created, not the name.

**resource_group_name:**
The name of the Resource Group to put the app service into. If resource_group_is_new is set to true, this will try to create a new one.

**region:**
The region where all the resources are/will be located.

**env:**
The environment of the application. Thiw will be added as a tag.
If the env is set to _"stg_ or _"prod"_ (not case sensitive) the app service will have a slot.

**app_service_tags:**
_optional_ A group of tags to add to the app service.

**app_service_settings:**
_optional_ A group of environment variables that the app service will have.

**key_vault_key_permissions:**
_optional_ The list of permissions the app will have to keys

**key_vault_certificate_permissions:**
_optional_ The list of permissions the app will have to certificates

**key_vault_secret_permissions:**
_optional_ The list of permissions the app will have to secrets

**cors_allowed_origins:**
_optional_ List of allowed origins to this applications

**cors_support_credentials:**
_optional_ Indicates whether or not the requests can be made using credentials. False if not set

**key_vault_is_new:**
_optional_ If set to true, attemps to create a new Key Vault

**service_plan_is_new:** _optional_ If set to true, attemps to create a new Service Plan

**resource_group_is_new:**
_optional_ If set to true, attemps to create a new Resource Group. You need to set key_vault_is_new and service_plan_is_new to true when this is true.

**key_vault_sku:**
_optional_ Used when key_vault_is_new set to true. Defaults to standard. Possible values are _"standard"_ and _"premium"_

**service_plan_kind:**
_optional_ Used when service_plan_is_new set to true. Defaults to Linux.
Possible values are _"Linux"_ and _"Windows"_

**service_plan_tier:**
_optional_ Used when service_plan_is_new set to true. Defaults to Premium

**service_plan_size:**
_optional_ Used when service_plan_is_new set to true. Defaults to P1V2.

**service_plan_reserved:**
_optional_ Used when service_plan_is_new set to true. Defaults to true for linux, and false for windows.

## Postgres

```h
module "<Name of Resource>" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//postgres-module"
  region = ""
  resource_group_name = ""
  key_vault = ""
  env = ""
  storage_amt = 0
  pg-server-name = ""
  pg-db-name = ""
}
```

**region:**
Region where the database will be

**resource_group_name:**
Resource group where the database will be

**key_vault:**
Key Vault containing the secrets for the App Servce

**env:**
Environment of the app

**storage_amt:**
Amount of storage for the DB in Mb. Must be multiple of 1024, and the minimum value is 5120

**pg-server-name:**
Name of the database server

**pg-db-name:**
Name of the database

## SQL Server

```h
module "<Name of Resource>" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//database-module"
  region = ""
  resource_group_name = ""
  key_vault = ""
  env = ""
  sql-server-name = ""
  sql-db-name = ""
}
```

**region:**
Region where the database will be

**resource_group_name:**
Resource group where the database will be

**key_vault:**
Key Vault containing the secrets for the App Servce

**env:**
Environment of the app

**sql-server-name:**
Name of the database server

**sql-db-name:**
Name of the database
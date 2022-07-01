# Terraform
This directory structure houses a series of files which will house the inputs for your infrastructure. Treat them like environment variables and fill out accordingly. The build / release pipelines will run the infra

## App service block
```
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

## Postgres block
```
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
module "al-function-mod" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//function-module?ref=azFunctionMod"
  resource_group_name = "rg-matching-algorithm"
  region = "southcentralus"
  storage_acct_name = "almatchalgosa"
  env = "prod"
  purpose_tag = "truck match v3"
  owner_tag = "DEDODS"
  function_name = "truck-matching-algorithm-Prod"
  os_type = "linux"
  service_plan_name = "match-algo-prod-asp"
  service_plan_is_new = true
  service_plan_tier = "Standard"
  service_plan_size = "P2v2"
  service_plan_kind = "Linux"
  service_plan_reserved = true
  func_runtime_lang = "python"
}
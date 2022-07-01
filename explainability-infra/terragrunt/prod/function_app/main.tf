module "al-function-mod" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//function-module?ref=cost-prediction-infra-init"
  resource_group_name = "rg-matching-algorithm"
  region = "southcentralus"
  storage_acct_name    = "almatchexplainsa"
  env = "prod"
  purpose_tag = "truck match explainability"
  owner_tag = "DEDODS"
  function_name = "truck-matching-explainability-Prod"
  os_type = "linux"
  service_plan_name   = "match-explainability-prod-sp"
  service_plan_is_new = true
  service_plan_size   = "P1V3"
  service_plan_tier   = "Premium"
  service_plan_kind = "Linux"
  service_plan_reserved = true
  func_runtime_lang = "python"
}

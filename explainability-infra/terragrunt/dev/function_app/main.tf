module "al-function-mod" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//function-module?ref=azFunctionMod"
  resource_group_name = "rg-matching-algorithm"
  region = "southcentralus"
  storage_acct_name = "almatchalgosa"
  env = "dev"
  purpose_tag = "explainability dev env"
  owner_tag = "DEDODS"
  function_name = "truck-matching-explainability-Dev"
  os_type = "linux"
  service_plan_name = "match-algo-asp"
}
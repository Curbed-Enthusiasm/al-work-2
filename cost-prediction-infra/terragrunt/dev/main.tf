
locals {
  resource_group_name = "rg-cost-prediction"
  storage_account    = substr("alcostpred${local.region}", 0, 23)
  service_plan_is_new = true
  service_plan_name   = "cost-prediction-nonprod-sp"
  env                 = "dev"
  region              = "centralus"
}

module "al-function-mod" {
  source              = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//function-module?ref=v0.4.0"
  resource_group_name = local.resource_group_name
  region              = local.region
  storage_acct_name   = local.storage_account
  storage_acct_is_new = true
  env                 = local.env
  purpose_tag         = "cost predition data science model"
  owner_tag           = "DEDODS"
  function_name       = "al-cost-prediction-${local.env}-${local.region}"
  os_type             = "linux"
  service_plan_name   = local.service_plan_name
  service_plan_is_new = true
  service_plan_size   = "P3v2"
  service_plan_tier   = "PremiumV2"
  func_runtime_lang   = "python"
}
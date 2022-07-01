module "aks_resource_group" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//aks-resource-group-module?ref=aks-cluster"
  environment = "nonprod"
  region = "Central US"
  subscription_id = "2391022b-04f5-42a5-838d-1c0a301df4c8"
}

output "resource_group" {
  value = module.aks_resource_group.resource_group
}

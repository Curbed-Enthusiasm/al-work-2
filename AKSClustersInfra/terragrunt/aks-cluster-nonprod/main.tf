module "aks_cluster" {
  source = "git::ssh://git@vs-ssh.visualstudio.com/v3/ArriveLogistics/Accelerate/terraform-modules//aks-module?ref=aks-cluster"
  resource_group_name = "aks-cluster-nonprod"
  environment = "nonprod"
  region = "Central US"
  subscription_id = "2391022b-04f5-42a5-838d-1c0a301df4c8"
  ad_group_id = "a22b427d-c4a0-49f9-8043-4a8d173bb321"
}

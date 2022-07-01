output "endpoint" {
  value = module.al-cosmos-mod.endpoint
}

output "primary_key" {
  value = module.al-cosmos-mod.primary_key
  sensitive = true
}

output "db_id" {
  value = module.al-cosmos-mod.db_id
}

output "container_id" {
  value = module.al-cosmos-mod.container_id
}

output "kdh_rds_arn" {
  value = module.kdh_database.rds_arn
}

output "kdh_rds_hostname" {
  value     = module.kdh_database.rds_hostname
  sensitive = true
}

output "kdh_rds_port" {
  value     = module.kdh_database.rds_port
  sensitive = true
}

output "kdh_rds_username" {
  value     = module.kdh_database.rds_username
  sensitive = true
}

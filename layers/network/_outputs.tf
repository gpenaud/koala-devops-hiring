
output "kdh_vpc_id" {
  value = module.kdh_network.vpc_id
}

output "kdh_vpc_cidr" {
  value = module.kdh_network.vpc_cidr
}

output "kdh_public_subnet_ids" {
  value = module.kdh_network.public_subnet_ids
}

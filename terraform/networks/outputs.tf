output "parcel-perform-interview-vpc" {
  value = module.network_dev.vpc
}

output "db-subnet-group" {
  value = module.network_dev.db-subnet-group
}

output "public-subnet-0" {
  value = module.network_dev.public-subnet-0
}

output "public-subnet-1" {
  value = module.network_dev.public-subnet-1
}

output "public-subnet-2" {
  value = module.network_dev.public-subnet-2
}

output "private-subnet-0" {
  value = module.network_dev.private-subnet-0
}

output "private-subnet-1" {
  value = module.network_dev.private-subnet-1
}

output "private-subnet-2" {
  value = module.network_dev.private-subnet-2
}

output "route-table" {
  value = module.network_dev.route-table
}

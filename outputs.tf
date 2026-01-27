# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.security.web_security_group_id
}

# Database Information
output "mongodb_instance_id" {
  description = "ID of the MongoDB instance"
  value       = module.database.mongodb_instance_id
}

output "mongodb_private_ip" {
  description = "Private IP of MongoDB server"
  value       = module.database.mongodb_private_ip
}

output "mongodb_connection_string" {
  description = "MongoDB connection string for your application"
  value       = module.database.mongodb_connection_string
}

output "mongodb_security_group_id" {
  description = "ID of the MongoDB security group"
  value       = module.security.database_security_group_id
}

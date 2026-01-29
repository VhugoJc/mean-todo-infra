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

# Application Server Information
output "app_instance_ids" {
  description = "IDs of the application server instances"
  value       = module.compute.app_instance_ids
}

output "app_public_ips" {
  description = "Public IPs of the application servers"
  value       = module.compute.app_public_ips
}

output "app_private_ips" {
  description = "Private IPs of the application servers"
  value       = module.compute.app_private_ips
}

output "app_public_dns_names" {
  description = "Public DNS names of the application servers"
  value       = module.compute.app_public_dns_names
}

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "frontend_url" {
  description = "Frontend application URL (via load balancer)"
  value       = module.load_balancer.frontend_url
}

output "target_group_arn" {
  description = "ARN of the load balancer target group"
  value       = module.load_balancer.target_group_arn
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

# NAT Gateway Information
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.network.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = module.network.nat_public_ips
}

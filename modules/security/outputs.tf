output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.web_security_group.security_group_id
}

output "web_security_group_arn" {
  description = "ARN of the web security group"
  value       = module.web_security_group.security_group_arn
}

output "web_security_group_name" {
  description = "Name of the web security group"
  value       = module.web_security_group.security_group_name
}

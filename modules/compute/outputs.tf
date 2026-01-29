output "app_instance_ids" {
  description = "Application server instance IDs"
  value       = aws_instance.app_server[*].id
}

output "app_public_ips" {
  description = "Application server public IP addresses"
  value       = aws_instance.app_server[*].public_ip
}

output "app_private_ips" {
  description = "Application server private IP addresses"
  value       = aws_instance.app_server[*].private_ip
}

output "app_public_dns_names" {
  description = "Application server public DNS names"
  value       = aws_instance.app_server[*].public_dns
}

output "app_instance_id" {
  description = "Application server instance ID"
  value       = aws_instance.app_server.id
}

output "app_public_ip" {
  description = "Application server public IP address"
  value       = aws_instance.app_server.public_ip
}

output "app_private_ip" {
  description = "Application server private IP address"
  value       = aws_instance.app_server.private_ip
}

output "app_public_dns" {
  description = "Application server public DNS name"
  value       = aws_instance.app_server.public_dns
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "mongodb_instance_id" {
  description = "MongoDB instance ID"
  value       = aws_instance.mongodb.id
}

output "mongodb_private_ip" {
  description = "MongoDB private IP address"
  value       = aws_instance.mongodb.private_ip
}

output "mongodb_connection_string" {
  description = "MongoDB connection string for applications"
  value       = "mongodb://${aws_instance.mongodb.private_ip}:27017"
  sensitive   = false
}

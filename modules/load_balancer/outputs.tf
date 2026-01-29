output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.app_lb.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.app_lb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.app_tg.name
}

output "frontend_url" {
  description = "Frontend application URL via load balancer"
  value       = "http://${aws_lb.app_lb.dns_name}"
}

output "listener_arn" {
  description = "ARN of the load balancer listener"
  value       = aws_lb_listener.app_listener.arn
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group ID for the load balancer"
  type        = string
}

variable "target_instance_ids" {
  description = "List of instance IDs to attach to the target group"
  type        = list(string)
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "listener_port" {
  description = "Port on which the load balancer listens"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the load balancer listener"
  type        = string
  default     = "HTTP"
}

# Health Check Configuration
variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks before marking target healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking target unhealthy"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "Amount of time in seconds during which no response is failure"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Approximate amount of time in seconds between health checks"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Destination for the health check request"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "Response codes to indicate a healthy service"
  type        = string
  default     = "200"
}

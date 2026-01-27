variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for application server"
  type        = string
}

variable "web_security_group_id" {
  description = "Web security group ID"
  type        = string
}

variable "app_ami_id" {
  description = "AMI ID for application server"
  type        = string
}

variable "app_instance_type" {
  description = "Instance type for application server"
  type        = string
  default     = "t3.medium"
}

variable "app_storage_size" {
  description = "Storage size for application server (GB)"
  type        = number
  default     = 20
}

variable "github_repo_url" {
  description = "GitHub repository URL for the application"
  type        = string
  default     = "https://github.com/VhugoJc/mearn-todo-app.git"
}

variable "app_directory" {
  description = "Directory within the repo containing the frontend app"
  type        = string
  default     = "frontend"
}

variable "app_port" {
  description = "Port where the Angular app will be served"
  type        = number
  default     = 4200
}

variable "deployment_mode" {
  description = "Deployment mode: 'production' for built files or 'development' for ng serve"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["production", "development"], var.deployment_mode)
    error_message = "Deployment mode must be either 'production' or 'development'."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (optional for debugging)"
  type        = string
  default     = ""
}

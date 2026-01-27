variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for database"
  type        = string
}

variable "database_security_group_id" {
  description = "Database security group ID"
  type        = string
}

variable "mongodb_ami_id" {
  description = "AMI ID for MongoDB instance (region-specific)"
  type        = string
}

variable "mongodb_instance_type" {
  description = "Instance type for MongoDB"
  type        = string
  default     = "t3.medium"
}

variable "mongodb_storage_size" {
  description = "Storage size for MongoDB data volume (GB)"
  type        = number
  default     = 50
}

variable "mongodb_version" {
  description = "MongoDB version to install"
  type        = string
  default     = "6.0"
}

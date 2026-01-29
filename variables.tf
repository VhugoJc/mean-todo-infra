variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "mean-todo"
}

# AWS
variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "eu-west-1"
}

variable "ami_id" {
  description = "ID de la AMI para las instancias EC2"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 en eu-west-1
}

variable "mongodb_ami_id" {
  description = "AMI ID for MongoDB database instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 - update with correct AMI for your region
}

variable "mongo_admin_user" {
  description = "MongoDB admin username"
  type        = string
}

variable "mongo_admin_password" {
  description = "MongoDB admin password"
  type        = string
}

variable "mongo_db_name" {
  description = "Name of the MongoDB database to create"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para la VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# RED
variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subredes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subredes privadas"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

# Backwards compatibility - keeping old variables but deprecated
variable "public_subnet_cidr" {
  description = "CIDR de la subred pública (deprecated - use public_subnet_cidrs)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR de la subred privada (deprecated - use private_subnet_cidrs)"
  type        = string
  default     = "10.0.2.0/24"
}

# Database Configuration
variable "mongodb_instance_type" {
  description = "Instance type for MongoDB database"
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

# Application Server Configuration
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

# Application Deployment Configuration
variable "github_repo_url" {
  description = "GitHub repository URL for the MEAN todo application"
  type        = string
  default     = "https://github.com/VhugoJc/mearn-todo-app.git"
}

variable "app_directory" {
  description = "Directory name within the repository containing the frontend application"
  type        = string
  default     = "frontend"
}

variable "instance_count" {
  description = "Number of application server instances to create"
  type        = number
  default     = 2
}

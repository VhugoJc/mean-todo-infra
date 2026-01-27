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

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para la VPC"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

# RED
variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR de la subred pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR de la subred privada"
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

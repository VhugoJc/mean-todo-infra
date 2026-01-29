terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = [var.public_subnet_cidr]
  private_subnet_cidrs = [var.private_subnet_cidr]
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  vpc_cidr     = var.vpc_cidr
}

module "database" {
  source = "./modules/database"

  project_name               = var.project_name
  private_subnet_id          = module.network.private_subnet_ids[0]
  database_security_group_id = module.security.database_security_group_id
  mongodb_ami_id             = var.mongodb_ami_id
  mongodb_instance_type      = var.mongodb_instance_type
  mongodb_version            = var.mongodb_version
  mongo_admin_user           = var.mongo_admin_user
  mongo_admin_password       = var.mongo_admin_password
  mongo_db_name              = var.mongo_db_name

  # Explicit dependency to ensure private networking is fully ready
  # before creating MongoDB instance. This prevents MongoDB from being
  # created before NAT Gateway and private routes are functional.
  depends_on = [
    module.network
  ]
}

module "compute" {
  source = "./modules/compute"
  
  project_name          = var.project_name
  public_subnet_id      = module.network.public_subnet_ids[0]
  web_security_group_id = module.security.web_security_group_id
  app_ami_id            = var.ami_id
  app_instance_type     = var.app_instance_type
  app_storage_size      = var.app_storage_size
  github_repo_url       = var.github_repo_url
  app_directory         = var.app_directory
  
  # Database connection info
  mongodb_private_ip    = module.database.mongodb_private_ip
  mongodb_instance_id   = module.database.mongodb_instance_id
  mongo_admin_user      = var.mongo_admin_user
  mongo_admin_password  = var.mongo_admin_password
  mongo_db_name         = var.mongo_db_name
  
  # Ensure compute waits for database to be fully ready
  depends_on = [module.database]
}

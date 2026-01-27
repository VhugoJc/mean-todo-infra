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
}

resource "aws_instance" "example" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.network.public_subnet_ids[0]
  vpc_security_group_ids      = [module.security.web_security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-instance"
  }
}
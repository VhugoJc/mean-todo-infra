# MEAN Todo Infrastructure

This Terraform project provisions AWS infrastructure for a MEAN stack todo application using a modular architecture.

## Architecture

The infrastructure includes:
- **Network Module**: VPC with public and private subnets across multiple availability zones, Internet Gateway, and NAT Gateway
- **Security Module**: Security groups for web servers with HTTP, HTTPS, and SSH access
- **Compute**: EC2 instance in the public subnet with proper security group attachment

## Project Structure

```
.
├── main.tf                    # Main configuration and module orchestration
├── variables.tf               # Root variable definitions
├── terraform.tfvars.example  # Example variable values
├── readme.md                  # This documentation
└── modules/
    ├── network/               # Networking resources
    │   ├── main.tf           # VPC, subnets, gateways
    │   ├── variables.tf      # Network module variables
    │   └── outputs.tf        # Network module outputs
    └── security/              # Security resources
        ├── main.tf           # Security groups
        ├── variables.tf      # Security module variables
        └── outputs.tf        # Security module outputs
```

## Module Design

### Network Module
- **Purpose**: Manages all networking infrastructure
- **Resources**: VPC, public/private subnets, Internet Gateway, NAT Gateway
- **Outputs**: VPC ID, subnet IDs, gateway IDs

### Security Module  
- **Purpose**: Manages security groups and access control
- **Resources**: Web server security group with configurable rules
- **Dependencies**: Requires VPC ID from network module

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 0.12 installed

## Authentication

**Important:** This project uses AWS CLI credentials for security. Configure your AWS credentials using one of these methods:

```bash
# Option 1: AWS CLI (Recommended)
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Option 3: IAM roles (recommended for production)
```

## Usage

1. Clone this repository and navigate to the project directory

2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your desired values

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Plan the deployment:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Variables

| Variable | Description | Default | Module |
|----------|-------------|---------|--------|
| `aws_region` | AWS region for deployment | `eu-west-1` | Root |
| `project_name` | Name prefix for resources | `mean-todo` | All |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` | Network |
| `public_subnet_cidr` | CIDR for public subnet | `10.0.1.0/24` | Network |
| `private_subnet_cidr` | CIDR for private subnet | `10.0.2.0/24` | Network |
| `availability_zones` | AZs for deployment | `["eu-west-1a", "eu-west-1b"]` | Network |
| `ami_id` | EC2 AMI ID | `ami-0c55b159cbfafe1f0` | Root |
| `instance_type` | EC2 instance type | `t2.micro` | Root |

## Security Features

- **No Hardcoded Credentials**: Uses AWS CLI/environment credentials
- **Modular Security**: Dedicated security module for access control
- **Web Server Security Group**: 
  - HTTP (80), HTTPS (443), SSH (22) inbound access
  - All outbound traffic allowed
  - Configurable CIDR blocks
- **Network Isolation**: Private subnets with NAT Gateway for secure connectivity
- **Least Privilege**: Security groups follow principle of least privilege

## Extending the Infrastructure

### Adding New Security Groups
Add new security groups in the `modules/security/main.tf`:

```hcl
module "database_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.project_name}-db-sg"
  
  description = "Security group for ${var.project_name} database"
  vpc_id      = var.vpc_id
  
  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.web_security_group.security_group_id
    }
  ]
  
  tags = {
    Name = "${var.project_name}-db-sg"
    Type = "Database"
  }
}
```

### Adding Multiple Environments
Use Terraform workspaces or separate tfvars files:

```bash
# Development environment
terraform apply -var-file="dev.tfvars"

# Production environment  
terraform apply -var-file="prod.tfvars"
```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Best Practices Implemented

✅ **Modular Architecture**: Separated concerns into network and security modules  
✅ **Security**: No hardcoded credentials, proper IAM practices  
✅ **Scalability**: Easy to extend with new modules and resources  
✅ **Documentation**: Comprehensive README and variable descriptions  
✅ **Version Control**: Provider version constraints for consistency  
✅ **Resource Tagging**: Consistent tagging strategy across resources

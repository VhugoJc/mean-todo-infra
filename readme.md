# MEAN Todo Infrastructure

This Terraform project provisions complete AWS infrastructure for a MEAN stack todo application with MongoDB database using a modular architecture.

## Architecture

The infrastructure includes:
- **Network Module**: VPC with public and private subnets, Internet Gateway, and NAT Gateway for secure connectivity
- **Security Module**: Separate security groups for web servers and database with proper access controls
- **Database Module**: MongoDB instance in private subnet with automated setup and configuration
- **Compute Module**: Frontend/Backend application server in public subnet with dynamic environment configuration

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
    ├── security/              # Security resources
    │   ├── main.tf           # Security groups for web and database
    │   ├── variables.tf      # Security module variables
    │   └── outputs.tf        # Security module outputs
    ├── database/              # MongoDB database resources
    │   ├── main.tf           # MongoDB EC2 instance
    │   ├── variables.tf      # Database module variables
    │   ├── outputs.tf        # Database module outputs
    │   └── userdata.sh       # MongoDB installation and setup script
    └── compute/               # Application server resources
        ├── main.tf           # Frontend/Backend EC2 instance
        ├── variables.tf      # Compute module variables
        ├── outputs.tf        # Compute module outputs
        └── userdata.sh       # Application setup and configuration script
```

## Module Design

### Network Module
- **Purpose**: Manages all networking infrastructure with proper isolation
- **Resources**: VPC, public/private subnets, Internet Gateway, NAT Gateway
- **Dependencies**: Uses explicit dependency management to ensure proper creation order
- **Outputs**: VPC ID, subnet IDs, gateway IDs

### Security Module  
- **Purpose**: Manages security groups for web and database tiers
- **Resources**: 
  - Web security group: HTTP, HTTPS, SSH, Backend API access
  - Database security group: MongoDB access from web servers only
- **Dependencies**: Requires VPC ID from network module
- **Security**: Implements principle of least privilege

### Database Module
- **Purpose**: Manages MongoDB database instance in private subnet
- **Resources**: EC2 instance with automated MongoDB 6.0 installation
- **Features**:
  - Automated MongoDB setup and configuration
  - Database initialization with application schema
  - Network connectivity testing and verification
  - Status monitoring and logging
- **Dependencies**: Requires network and security modules

### Compute Module
- **Purpose**: Manages application server for frontend and backend
- **Resources**: EC2 instance with full MEAN stack deployment
- **Features**:
  - Automated Node.js, Angular CLI, and MongoDB client installation
  - Dynamic frontend environment configuration
  - Integration with setenv.js script for API URL setup
  - Nginx reverse proxy configuration
  - Backend API with MongoDB connectivity
  - Status monitoring and debugging endpoints

## Key Features

### 🚀 **Complete MEAN Stack Deployment**
- Automated Node.js and Angular setup
- MongoDB 6.0 with proper configuration
- Nginx reverse proxy for production-ready deployment

### 🔧 **Dynamic Environment Configuration**
- Frontend automatically configures backend API URL using EC2 metadata
- Integration with custom `setenv.js` script for environment setup
- Real-time API URL logging for debugging

### 🔒 **Security & Network Isolation**
- MongoDB in private subnet, accessible only from application servers
- Web application in public subnet with internet access
- Security groups following least privilege principles
- NAT Gateway for secure outbound connectivity from private resources

### 📊 **Monitoring & Debugging**
- Status endpoints for health checking
- Comprehensive logging for both MongoDB and application setup
- Network connectivity verification with retry logic
- Debug information available via web interface

### ⚡ **Reliability & Dependencies**
- Explicit dependency management prevents race conditions
- Network infrastructure ready before application deployment
- MongoDB connectivity verification before application start
- Retry mechanisms for robust service initialization

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 0.12 installed
3. Git repository with MEAN stack application (frontend/backend structure)

## Quick Start

1. **Clone and Configure**
   ```bash
   git clone <your-repo>
   cd mean-todo-infra
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Update Configuration**
   Edit `terraform.tfvars` with your values:
   ```hcl
   github_repo_url = "https://github.com/yourusername/your-mean-app.git"
   project_name = "your-project"
   aws_region = "us-east-1"
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Access Your Application**
   After deployment, access your app at the provided frontend URL from terraform outputs.

## Configuration Variables

### Core Configuration
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` | `us-west-2` |
| `project_name` | Name prefix for resources | `mean-todo` | `my-app` |
| `github_repo_url` | Git repository with your MEAN app | Required | `https://github.com/user/app.git` |

### Network Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` |
| `public_subnet_cidr` | CIDR for public subnet | `10.0.1.0/24` |
| `private_subnet_cidr` | CIDR for private subnet | `10.0.2.0/24` |
| `availability_zones` | AZs for deployment | `["us-east-1a", "us-east-1b"]` |

### Database Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `mongodb_ami_id` | AMI ID for MongoDB instance | `ami-011899242bb902164` |
| `mongodb_instance_type` | MongoDB instance type | `t3.medium` |
| `mongodb_version` | MongoDB version to install | `6.0` |
| `mongo_admin_user` | MongoDB admin username | `admin` |
| `mongo_admin_password` | MongoDB admin password | `password` |
| `mongo_db_name` | Application database name | `meantodo` |

### Application Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `ami_id` | AMI ID for app server | `ami-011899242bb902164` |
| `app_instance_type` | App server instance type | `t3.medium` |
| `app_directory` | Application directory name | `frontend` |

## Infrastructure Outputs

After successful deployment, you'll get these important outputs:

- `frontend_url` - Access your web application
- `mongodb_connection_string` - MongoDB connection details
- `app_public_ip` - Application server public IP
- `mongodb_private_ip` - Database server private IP
- `vpc_id` - VPC identifier
- `web_security_group_id` - Web security group ID
- `mongodb_security_group_id` - Database security group ID

## Authentication Setup

**Important:** Configure AWS credentials before deployment:

```bash
# Option 1: AWS CLI (Recommended)
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Option 3: IAM roles (recommended for production)
```

## Target Application

This infrastructure is designed to deploy the MEAN Todo application from:
**https://github.com/VhugoJc/mearn-todo-app**

The infrastructure automatically clones and configures this repository, including:
- Frontend Angular application setup
- Backend Node.js API configuration  
- MongoDB database integration
- Environment configuration for seamless connectivity

## Log Access & Monitoring

Since SSH access is not configured, all logs are accessible through the web interface at:

- **`/status/status.txt`** - Real-time deployment status and progress
- **`/status/backend.log`** - Backend API logs and MongoDB connectivity
- **`/status/angular.log`** - Frontend Angular development server logs
- **`/status/user-data.log`** - Complete infrastructure setup logs

Access these logs by visiting: `http://<app_public_ip>/status/` after deployment.

## Troubleshooting

### Common Issues

**MongoDB Connectivity Issues**
- Check security group rules allow traffic on port 27017
- Verify NAT Gateway is operational for private subnet access
- Check MongoDB logs at `/status/user-data.log` via web interface

**Application Not Starting**
- Verify GitHub repository URL is accessible
- Check userdata logs at `/status/user-data.log` via web interface
- Ensure Node.js dependencies install correctly

**Frontend Environment Configuration**
- Verify `setenv.js` script exists in `/frontend/scripts/`
- Check API_URL is correctly set in browser developer tools
- Confirm backend API is accessible from frontend

### Debugging via Web Interface

Since SSH access is not configured, use the web-based log access:

```bash
# Check infrastructure status
terraform output

# Access logs via browser
http://<app_public_ip>/status/status.txt      # Deployment progress
http://<app_public_ip>/status/backend.log     # Backend application logs  
http://<app_public_ip>/status/angular.log     # Frontend application logs
http://<app_public_ip>/status/user-data.log   # Complete setup logs
```


## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Security Features

- **Network Isolation**: MongoDB in private subnet, only accessible from application servers
- **Security Groups**: Principle of least privilege with specific port access
- **No Hardcoded Credentials**: Uses AWS CLI/environment credentials  
- **Encrypted Storage**: EBS volumes encrypted at rest
- **NAT Gateway**: Secure outbound internet access for private resources

## Best Practices Implemented

✅ **Complete MEAN Stack**: Full MongoDB + Express + Angular + Node.js deployment  
✅ **Modular Architecture**: Separated network, security, database, and compute concerns  
✅ **Security First**: Network isolation, security groups, encrypted storage  
✅ **Reliability**: Dependency management, retry logic, health checking  
✅ **Automation**: Fully automated setup from infrastructure to application deployment  
✅ **Monitoring**: Comprehensive logging and status endpoints  
✅ **Scalability**: Easy to extend with additional environments or features  
✅ **Documentation**: Complete setup and troubleshooting guides

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the infrastructure deployment
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

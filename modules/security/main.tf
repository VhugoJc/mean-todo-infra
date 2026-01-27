module "web_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.project_name}-web-sg"
  
  description = "Security group for ${var.project_name} web servers"
  vpc_id      = var.vpc_id
  
  ingress_cidr_blocks = var.ingress_cidr_blocks
  ingress_rules       = var.ingress_rules
  
  egress_cidr_blocks = var.egress_cidr_blocks
  egress_rules       = var.egress_rules
  
  tags = {
    Name = "${var.project_name}-web-sg"
    Type = "WebServer"
  }
}

# Additional security groups can be added here for different tiers
# For example: database, application, load balancer security groups

# Frontend/Backend Application Server
resource "aws_instance" "app_server" {
  ami           = var.app_ami_id
  instance_type = var.app_instance_type
  subnet_id     = var.public_subnet_id
  
  vpc_security_group_ids      = [var.web_security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name  # Add key for debugging

  # Additional storage if needed
  root_block_device {
    volume_type = "gp3"
    volume_size = var.app_storage_size
    encrypted   = true
  }

  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {
    github_repo_url  = var.github_repo_url
    app_directory    = var.app_directory
    app_port         = var.app_port
    deployment_mode  = var.deployment_mode
  }))

  tags = {
    Name = "${var.project_name}-app-server"
    Type = "Application"
  }
}

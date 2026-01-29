# Frontend/Backend Application Servers
resource "aws_instance" "app_server" {
  count = var.instance_count

  ami           = var.app_ami_id
  instance_type = var.app_instance_type
  subnet_id     = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  
  vpc_security_group_ids      = [var.web_security_group_id]
  associate_public_ip_address = true

  # Additional storage if needed
  root_block_device {
    volume_type = "gp3"
    volume_size = var.app_storage_size
    encrypted   = true
  }

  # Add a delay before starting userdata to give MongoDB time to be ready
  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {
    github_repo_url      = var.github_repo_url
    app_directory        = var.app_directory
    app_port             = var.app_port
    deployment_mode      = var.deployment_mode
    mongodb_private_ip   = var.mongodb_private_ip
    mongo_admin_user     = var.mongo_admin_user
    mongo_admin_password = var.mongo_admin_password
    mongo_db_name        = var.mongo_db_name
  }))

  tags = {
    Name = "${var.project_name}-app-server-${count.index + 1}"
    Type = "Application"
  }
}

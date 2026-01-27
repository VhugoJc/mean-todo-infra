# MongoDB EC2 instance
resource "aws_instance" "mongodb" {
  ami           = var.mongodb_ami_id
  instance_type = var.mongodb_instance_type
  subnet_id     = var.private_subnet_id
  
  vpc_security_group_ids = [var.database_security_group_id]

  # Additional storage for MongoDB data
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = var.mongodb_storage_size
    encrypted   = true
  }

  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {
    mongodb_version = var.mongodb_version
  }))

  tags = {
    Name = "${var.project_name}-mongodb"
    Type = "Database"
  }
}

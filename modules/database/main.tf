# MongoDB EC2 instance
resource "aws_instance" "mongodb" {
  ami           = var.mongodb_ami_id
  instance_type = var.mongodb_instance_type
  subnet_id     = var.private_subnet_id
  
  vpc_security_group_ids = [var.database_security_group_id]

  user_data_base64 = base64encode(templatefile("${path.module}/userdata_simple.sh", {
    mongodb_version = var.mongodb_version
    mongo_admin_user = var.mongo_admin_user
    mongo_admin_password = var.mongo_admin_password
    mongo_db_name = var.mongo_db_name
  }))

  tags = {
    Name = "${var.project_name}-mongodb"
    Type = "Database"
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-app-lb"
    Type = "LoadBalancer"
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-app-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-app-tg"
    Type = "TargetGroup"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  count            = length(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.target_port
}

# Load Balancer Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

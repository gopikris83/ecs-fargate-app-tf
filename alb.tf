###########################################################
# AWS Application Load balancer
###########################################################
resource "aws_alb" "alb" {
  name               = "ecsfargateapp-load-balancer"
  subnets            = var.public_subnets
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_groups]

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

resource "aws_alb_target_group" "alb-tgp" {
  name        = "ecsfargateapp-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.log-vpc

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 100
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-tgp.id
  }
}


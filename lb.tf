resource "aws_alb" "staging" {
  name               = "alb-${var.env_suffix}"
  subnets            = aws_subnet.public.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  internal           = false

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_alb.staging.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging.id
  }
}

resource "aws_lb_target_group" "staging" {
  vpc_id                = aws_vpc.cluster_vpc.id
  name                  = "service-alb-tg-${var.env_suffix}"
  port                  = 8080
  protocol              = "HTTP"
  target_type           = "ip"
  deregistration_delay  = 30

  health_check {
    protocol            = "HTTP"
    interval            = 120
    port                = "8080"
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}
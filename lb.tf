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
  name                  = "service-alb-tg-gateway"
  port                  = 8080
  protocol              = "HTTP"
  target_type           = "instance"
  deregistration_delay  = 30

  health_check {
    protocol            = "HTTP"
    interval            = 120
    port                = "8080"
    path                = "/actuator/health"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "internal_staging" {
  name               = "ecs-internal-alb"
  subnets            = aws_subnet.private.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb.id]
  internal           = true

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}

resource "aws_lb_target_group" "internal_service" {
  vpc_id      = aws_vpc.cluster_vpc.id
  name        = "ecs-internal-service-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    path                = "/actuator/health"
    matcher             = "200-299"
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}

resource "aws_lb_target_group" "internal_service_point" {
  vpc_id      = aws_vpc.cluster_vpc.id
  name        = "ecs-internal-service-point-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    path                = "/actuator/health"
    matcher             = "200-299"
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}

resource "aws_lb_listener" "internal_http_forward" {
  load_balancer_arn = aws_alb.internal_staging.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_service.arn
  }

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}

resource "aws_lb_listener_rule" "service_point_rule" {
  listener_arn = aws_lb_listener.internal_http_forward.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/api/internal/*"] 
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_service_point.arn
  }
}

resource "aws_security_group" "internal_lb" {
  vpc_id = aws_vpc.cluster_vpc.id
  name   = "internal-lb-sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.30.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}
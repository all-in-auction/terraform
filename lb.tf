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

resource "aws_route53_zone" "main" {
  name = "all-in-auction.site"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.all-in-auction.site"
  type    = "A"

  alias {
    name                   = aws_alb.staging.dns_name
    zone_id                = aws_alb.staging.zone_id
    evaluate_target_health = true
  }
}
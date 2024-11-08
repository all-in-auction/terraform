resource "aws_cloudwatch_log_group" "service" {
  name = "awslogs-service-staging-${var.env_suffix}"

  tags = {
    Environment = var.env_suffix
    Application = var.app_name
  }
}
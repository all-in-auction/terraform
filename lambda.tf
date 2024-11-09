resource "aws_iam_role" "lambda_ec2_control_role" {
  name = "lambda_ec2_control_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_ec2_control_policy" {
  name   = "lambda_ec2_control_policy"
  role   = aws_iam_role.lambda_ec2_control_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:StopInstances",
          "ec2:StartInstances"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "ec2_control_lambda_stop" {
  function_name = "ec2_control_lambda_stop"
  role          = aws_iam_role.lambda_ec2_control_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"
  
  environment {
    variables = {
      action = "stop"
    }
  }
}

resource "aws_lambda_function" "ec2_control_lambda_start" {
  function_name = "ec2_control_lambda_start"
  role          = aws_iam_role.lambda_ec2_control_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"
  
  environment {
    variables = {
      action = "start"
    }
  }
}

resource "aws_cloudwatch_event_rule" "ec2_stop_rule" {
  name        = "ec2_stop_rule"
  description = "Trigger EC2 instances stop at midnight"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "ec2_start_rule" {
  name        = "ec2_start_rule"
  description = "Trigger EC2 instances start at 9am"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ec2_stop_target" {
  rule      = aws_cloudwatch_event_rule.ec2_stop_rule.name
  arn       = aws_lambda_function.ec2_control_lambda_stop.arn
  input     = jsonencode({ "action": "stop" })
}

resource "aws_cloudwatch_event_target" "ec2_start_target" {
  rule      = aws_cloudwatch_event_rule.ec2_start_rule.name
  arn       = aws_lambda_function.ec2_control_lambda_start.arn
  input     = jsonencode({ "action": "start" })
}

resource "aws_lambda_permission" "allow_eventbridge_lambda_stop" {
  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_control_lambda_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_stop_rule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_lambda_start" {
  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_control_lambda_start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_start_rule.arn
}
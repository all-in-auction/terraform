resource "aws_s3_bucket" "auction_bucket" {
  bucket      = "auction-bucket"
  acl         = "private"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.auction_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [
          "${aws_s3_bucket.auction_bucket.arn}",
          "${aws_s3_bucket.auction_bucket.arn}/*"
        ],
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3_endpoint.id
          }
        }
      }
    ]
  })
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.cluster_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private_route : rt.id]

  tags = {
    Name = "s3-vpc-endpoint"
  }
}

resource "aws_iam_role_policy" "ecs_task_s3_access" {
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.auction_bucket.arn}",
          "${aws_s3_bucket.auction_bucket.arn}/*"
        ]
      }
    ]
  })
}

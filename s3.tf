resource "aws_s3_bucket" "auction_bucket" {
  bucket      = "all-in-auction-bucket"
  acl         = "private"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.auction_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # ECS 태스크 역할에 대한 접근 허용
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/inseogpt"
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject",
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
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "${aws_s3_bucket.auction_bucket.arn}",
          "${aws_s3_bucket.auction_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "models" {
  bucket = aws_s3_bucket.models.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPublish"
        Effect = "Allow"
        Principal = {
          AWS = var.publisher_principals
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.models.arn}/*"
      },
      {
        Sid    = "AllowConsume"
        Effect = "Allow"
        Principal = {
          AWS = var.consumer_principals
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.models.arn}/*"
      }
    ]
  })
}

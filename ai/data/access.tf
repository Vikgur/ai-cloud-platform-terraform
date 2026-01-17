resource "aws_s3_bucket_policy" "datasets" {
  bucket = aws_s3_bucket.datasets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principals
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.datasets.arn,
          "${aws_s3_bucket.datasets.arn}/*"
        ]
      }
    ]
  })
}

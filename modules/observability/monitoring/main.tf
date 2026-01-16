resource "aws_s3_bucket" "metrics" {
  bucket = "company-${var.environment}-metrics"
}

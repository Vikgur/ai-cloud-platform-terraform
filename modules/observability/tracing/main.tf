resource "aws_s3_bucket" "traces" {
  bucket = "company-${var.environment}-traces"
}

resource "aws_kms_key" "terraform" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "terraform" {
  name          = "alias/terraform-state"
  target_key_id = aws_kms_key.terraform.id
}

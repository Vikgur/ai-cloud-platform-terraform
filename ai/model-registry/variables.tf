variable "bucket_name" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "publisher_principals" {
  type = list(string)
}

variable "consumer_principals" {
  type = list(string)
}

variable "environment" {
  type = string
}

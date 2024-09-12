variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
}

variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "timestamp" {
  description = "The timestamp to be appended to the bucket name"
  type        = string
}

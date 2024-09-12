terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Bucket
resource "aws_s3_bucket" "bucket_name" {
  bucket = "${var.s3_bucket_name}-${var.timestamp}"
  acl    = "private"
  
}

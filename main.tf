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
  region     = "us-east-1"
  access_key = "" 
  secret_key = ""
}

# Bucket
resource "aws_s3_bucket" "bucket_name" {
  bucket = "aws-bucket-2026"
  acl    = "private"

}

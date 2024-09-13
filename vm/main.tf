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

# EC2 Instance
resource "aws_instance" "example" {
  ami           = var.ami_id               # Replace with your desired AMI ID
  instance_type = var.instance_type       # Replace with your desired instance type

  tags = {
    Name = "example-instance-${var.timestamp}"
  }
}

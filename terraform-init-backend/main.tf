terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terrafor-bucket" {
  bucket = "terraform-aws-backend-f2awcwvkfb"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  tags = {
    Name        = "terraform-aws-backend-f2awcwvKFb"
  }
}

resource "aws_dynamodb_table" "terraform-dynamodb-table" {
  name           = "terraform-aws-backend-f2awcwvkfb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-aws-backend-f2awcwvKFb"
  }
}